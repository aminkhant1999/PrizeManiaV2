process.env.NODE_ENV='test';process.env.SESSION_SECRET='test-secret-that-is-longer-than-thirty-two-characters';
const test=require('node:test');const assert=require('node:assert/strict');const request=require('supertest');const {createApp}=require('../app');
test('unknown route returns branded 404',async()=>{const response=await request(createApp({useMemoryStore:true})).get('/definitely-missing');assert.equal(response.status,404);assert.match(response.text,/Page Not Found/);});
test('admin route redirects anonymous visitors',async()=>{const response=await request(createApp({useMemoryStore:true})).get('/admin');assert.equal(response.status,302);assert.equal(response.headers.location,'/admin/login');});
test('state-changing form rejects missing CSRF token',async()=>{const response=await request(createApp({useMemoryStore:true})).post('/login').send('email=x&password=y');assert.equal(response.status,403);});
test('database-independent public forms render',async()=>{for(const path of ['/register','/login','/admin/login','/about','/contact']){const response=await request(createApp({useMemoryStore:true})).get(path);assert.equal(response.status,200,path);}});
