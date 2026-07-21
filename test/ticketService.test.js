const test=require('node:test');const assert=require('node:assert/strict');const {validateQuantity,generateTicketNumber}=require('../services/ticketService');
test('ticket quantity validation accepts permitted integers',()=>assert.equal(validateQuantity('3'),3));
test('ticket quantity validation blocks zero, fractions and excessive values',()=>{for(const value of [0,-1,1.5,21,'no'])assert.throws(()=>validateQuantity(value));});
test('ticket generation is collision resistant and draw-specific',()=>{const values=new Set(Array.from({length:500},()=>generateTicketNumber(7)));assert.equal(values.size,500);for(const value of values)assert.match(value,/^PM-7-/);});
