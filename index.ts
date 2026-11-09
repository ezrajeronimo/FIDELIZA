// FIDELIZA 8.3 | Edge Function privada para gerenciar usuários.
// Este arquivo NÃO utiliza service_role no navegador. A credencial fica
// apenas nos secrets do Supabase (SUPABASE_SERVICE_ROLE_KEY).
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const URL = Deno.env.get('SUPABASE_URL') ?? '';
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const ALLOWED_ORIGINS = new Set([
  'https://ezrajeronimo.github.io',
  'http://localhost:3000',
  'http://127.0.0.1:5500',
]);
const STORES = new Set(['GUARARAPES','RECIFE','RIOMAR','TACARUNA','PATTEO','PNWS','QUIOSQUE']);
const service = createClient(URL, SERVICE_KEY, { auth: { persistSession: false, autoRefreshToken: false } });

function headers(origin: string | null) {
  return {
    'Access-Control-Allow-Origin': origin && ALLOWED_ORIGINS.has(origin) ? origin : 'https://ezrajeronimo.github.io',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
    'Vary': 'Origin',
    'Content-Type': 'application/json',
  };
}
function response(body: unknown, status=200, origin: string | null=null) {
  return new Response(JSON.stringify(body), {status,headers:headers(origin)});
}
function validRoleStore(role: unknown, store: unknown): boolean {
  return (role==='admin' && (store===null || store===undefined || store==='')) || (role==='store' && typeof store==='string' && STORES.has(store));
}

Deno.serve(async (req: Request) => {
  const origin=req.headers.get('origin');
  if(req.method==='OPTIONS') return new Response(null,{status:204,headers:headers(origin)});
  if(req.method!=='POST') return response({error:'Método não permitido'},405,origin);
  if(origin && !ALLOWED_ORIGINS.has(origin)) return response({error:'Origem não autorizada'},403,origin);
  try {
    const bearer = req.headers.get('Authorization')?.match(/^Bearer\s+(.+)$/i)?.[1];
    if(!bearer) return response({error:'Sessão obrigatória'},401,origin);
    // verify_jwt desativado no gateway APENAS porque a função valida o token aqui.
    const {data:auth,error:authError}=await service.auth.getUser(bearer);
    if(authError || !auth.user) return response({error:'Sessão inválida'},401,origin);
    const {data:admin,error:profileError}=await service.from('fideliza_profiles').select('role').eq('user_id',auth.user.id).single();
    if(profileError || admin?.role!=='admin') return response({error:'Somente administradores podem executar esta ação'},403,origin);
    const body=await req.json();
    if(!body || typeof body!=='object') return response({error:'Dados inválidos'},400,origin);
    if(body.action==='list') {
      const {data:profiles,error}=await service.from('fideliza_profiles').select('user_id,name,role,store').order('name');
      if(error) throw error;
      const users=await Promise.all((profiles??[]).map(async (p: Record<string, unknown>) => {
        const {data}=await service.auth.admin.getUserById(String(p.user_id));
        return {...p,email:data?.user?.email??''};
      }));
      return response({users},200,origin);
    }
    if(body.action==='invite') {
      const name=String(body.name??'').trim().slice(0,100);
      const email=String(body.email??'').trim().toLowerCase();
      const role=body.role;const store=role==='admin'?null:body.store;
      if(name.length<2 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || !validRoleStore(role,store)) return response({error:'Nome, e-mail, perfil ou loja inválidos'},400,origin);
      const {data,error}=await service.auth.admin.inviteUserByEmail(email, {redirectTo:'https://ezrajeronimo.github.io/FIDELIZA/',data:{full_name:name}});
      if(error || !data?.user) return response({error:error?.message??'Convite não criado'},400,origin);
      const {error:profileErr}=await service.from('fideliza_profiles').upsert({user_id:data.user.id,name,role,store},{onConflict:'user_id'});
      if(profileErr) throw profileErr;
      return response({success:true},200,origin);
    }
    if(body.action==='update') {
      const id=String(body.user_id??'');const role=body.role;const store=role==='admin'?null:body.store;
      if(!/^[0-9a-fA-F-]{36}$/.test(id) || !validRoleStore(role,store)) return response({error:'Perfil inválido'},400,origin);
      if(id===auth.user.id && role!=='admin') return response({error:'Não é permitido remover sua própria administração'},403,origin);
      const {data:target,error:targetErr}=await service.from('fideliza_profiles').select('user_id,role').eq('user_id',id).single();
      if(targetErr||!target) return response({error:'Perfil não encontrado'},404,origin);
      if(target.role==='admin'&&role!=='admin') {
        const {count}=await service.from('fideliza_profiles').select('user_id',{count:'exact',head:true}).eq('role','admin');
        if((count??0)<=1) return response({error:'É necessário manter ao menos um administrador'},400,origin);
      }
      const {error}=await service.from('fideliza_profiles').update({role,store}).eq('user_id',id);
      if(error)throw error;
      return response({success:true},200,origin);
    }
    return response({error:'Ação não reconhecida'},400,origin);
  } catch(err) {
    console.error('fideliza-admin-users',err);
    return response({error:'Erro ao processar solicitação administrativa. Consulte logs da função.'},500,origin);
  }
});
