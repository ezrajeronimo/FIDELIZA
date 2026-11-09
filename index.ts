// FIDELIZA 8.6 — API administrativa protegida.
// Publique SOMENTE no Supabase Edge Functions. Nunca no GitHub Pages.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const URL = Deno.env.get('SUPABASE_URL') ?? '';
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const ALLOWED_ORIGINS = new Set(['https://ezrajeronimo.github.io','http://localhost:3000','http://127.0.0.1:5500']);
const STORES = new Set(['GUARARAPES','RECIFE','RIOMAR','TACARUNA','PATTEO','PNWS','QUIOSQUE']);
const adminClient = createClient(URL, SERVICE_KEY, { auth: { persistSession:false, autoRefreshToken:false } });
const uid = (s:unknown) => typeof s==='string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(s);
const cleanName = (s:unknown) => typeof s==='string'?s.trim().slice(0,100):'';
const cleanEmail = (s:unknown) => typeof s==='string'?s.trim().toLowerCase():'';
const validEmail=(s:string)=> /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s) && s.length<=254;
const validPassword=(s:unknown)=>typeof s==='string'&&s.length>=12&&s.length<=128;
const validRoleStore=(role:unknown,store:unknown)=>role==='admin' ? (store===null||store===undefined||store==='') : role==='store' && typeof store==='string' && STORES.has(store);
function headers(origin:string|null){return {
  'Access-Control-Allow-Origin':origin && ALLOWED_ORIGINS.has(origin)?origin:'https://ezrajeronimo.github.io',
  'Access-Control-Allow-Methods':'POST, OPTIONS',
  'Access-Control-Allow-Headers':'authorization, apikey, content-type, x-client-info',
  'Vary':'Origin', 'Content-Type':'application/json', 'Cache-Control':'no-store'
};}
function respond(value:unknown,status=200,origin:string|null=null){return new Response(JSON.stringify(value),{status,headers:headers(origin)})}

Deno.serve(async(req:Request)=>{
 const origin=req.headers.get('origin');
 if(req.method==='OPTIONS')return new Response(null,{status:204,headers:headers(origin)});
 if(req.method!=='POST')return respond({error:'Método não permitido'},405,origin);
 if(origin && !ALLOWED_ORIGINS.has(origin))return respond({error:'Origem não autorizada'},403,origin);
 if(!URL || !SERVICE_KEY)return respond({error:'Segredos do Supabase não configurados.'},500,origin);
 try{
  const bearer=req.headers.get('Authorization')?.match(/^Bearer\s+(.+)$/i)?.[1];
  if(!bearer)return respond({error:'Sessão obrigatória'},401,origin);
  // Não confie na chave pública nem na interface: valide token E perfil no servidor.
  const {data:auth,error:authError}=await adminClient.auth.getUser(bearer);
  if(authError||!auth.user)return respond({error:'Sessão inválida'},401,origin);
  const actor=auth.user.id;
  const {data:profile,error:profileError}=await adminClient.from('fideliza_profiles').select('role').eq('user_id',actor).single();
  if(profileError||profile?.role!=='admin')return respond({error:'Acesso exclusivo da administração'},403,origin);
  const body=await req.json();
  if(!body||typeof body!=='object')return respond({error:'Solicitação inválida'},400,origin);
  const action=body.action;
  if(action==='list'){
    const {data:profiles,error}=await adminClient.from('fideliza_profiles').select('user_id,name,role,store').order('name');
    if(error)throw error;
    const users=await Promise.all((profiles||[]).map(async(p:{user_id:string,name:string,role:string,store:string|null})=>{
      const {data}=await adminClient.auth.admin.getUserById(p.user_id);
      return {...p,email:data?.user?.email||''};
    }));
    return respond({users},200,origin);
  }
  if(action==='create'){
    const name=cleanName(body.name), email=cleanEmail(body.email), password=body.password;
    const role=body.role, store=role==='admin'?null:body.store;
    if(name.length<2||!validEmail(email)||!validPassword(password)||!validRoleStore(role,store))return respond({error:'Confira nome, e-mail, senha de 12+ caracteres, perfil e loja.'},400,origin);
    const {data:created,error:createError}=await adminClient.auth.admin.createUser({email,password,email_confirm:true,user_metadata:{full_name:name}});
    if(createError||!created?.user)return respond({error:createError?.message||'Falha ao criar usuário'},400,origin);
    const {error:profileErr}=await adminClient.from('fideliza_profiles').upsert({user_id:created.user.id,name,role,store},{onConflict:'user_id'});
    if(profileErr){
      // Evitar conta órfã quando perfil não é criado.
      await adminClient.auth.admin.deleteUser(created.user.id);
      throw profileErr;
    }
    return respond({success:true,user_id:created.user.id},200,origin);
  }
  if(action==='update'){
    const id=body.user_id, name=cleanName(body.name),email=cleanEmail(body.email);
    const role=body.role,store=role==='admin'?null:body.store;
    if(!uid(id)||name.length<2||!validEmail(email)||!validRoleStore(role,store))return respond({error:'Dados inválidos'},400,origin);
    if(id===actor && role!=='admin')return respond({error:'Você não pode retirar a própria administração'},400,origin);
    const {data:target,error:targetError}=await adminClient.from('fideliza_profiles').select('role').eq('user_id',id).single();
    if(targetError||!target)return respond({error:'Usuário não encontrado'},404,origin);
    if(target.role==='admin'&&role!=='admin'){
      const {count}=await adminClient.from('fideliza_profiles').select('user_id',{count:'exact',head:true}).eq('role','admin');
      if((count||0)<=1)return respond({error:'É obrigatório manter um administrador'},400,origin);
    }
    const {data:authData,error:authTargetError}=await adminClient.auth.admin.getUserById(id);
    if(authTargetError||!authData?.user)return respond({error:'Usuário Auth não encontrado'},404,origin);
    const oldEmail=authData.user.email||'';
    const {error:profileWriteError}=await adminClient.from('fideliza_profiles').update({name,role,store}).eq('user_id',id);
    if(profileWriteError)throw profileWriteError;
    const {error:authWriteError}=await adminClient.auth.admin.updateUserById(id,{email,email_confirm:true,user_metadata:{...authData.user.user_metadata,full_name:name}});
    if(authWriteError){console.error('partial update',id,authWriteError.message);return respond({error:'Perfil salvo, mas o e-mail não foi atualizado. Tente novamente ou corrija o e-mail anterior.'},409,origin);}
    return respond({success:true,email_changed:oldEmail!==email},200,origin);
  }
  if(action==='set_password'){
    const id=body.user_id,password=body.password;
    if(!uid(id)||!validPassword(password))return respond({error:'Escolha senha de 12 a 128 caracteres'},400,origin);
    const {data:profile}=await adminClient.from('fideliza_profiles').select('user_id').eq('user_id',id).single();
    if(!profile)return respond({error:'Usuário não encontrado'},404,origin);
    const {error}=await adminClient.auth.admin.updateUserById(id,{password});
    if(error)return respond({error:error.message},400,origin);
    return respond({success:true},200,origin);
  }
  if(action==='delete'){
    const id=body.user_id;
    if(!uid(id))return respond({error:'Usuário inválido'},400,origin);
    if(id===actor)return respond({error:'Não é permitido excluir a própria conta'},403,origin);
    const {data:target}=await adminClient.from('fideliza_profiles').select('role').eq('user_id',id).single();
    if(!target)return respond({error:'Usuário não encontrado'},404,origin);
    if(target.role==='admin'){
      const {count}=await adminClient.from('fideliza_profiles').select('user_id',{count:'exact',head:true}).eq('role','admin');
      if((count||0)<=1)return respond({error:'É obrigatório manter um administrador'},400,origin);
    }
    const {error}=await adminClient.auth.admin.deleteUser(id);
    if(error)return respond({error:error.message},400,origin);
    // Perfil sai por ON DELETE CASCADE; contatos, vendas e agenda das lojas permanecem.
    return respond({success:true},200,origin);
  }
  return respond({error:'Ação não reconhecida'},400,origin);
 }catch(err){
  console.error('fideliza-admin-users',err instanceof Error?err.message:String(err));
  return respond({error:'Não foi possível concluir a operação. Consulte os logs da Edge Function.'},500,origin);
 }
});
