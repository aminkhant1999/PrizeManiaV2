const drawModel=require('../models/drawModel');const ticketService=require('../services/ticketService');
async function showPurchase(req,res,next){try{const draw=await drawModel.getOpen();res.render('user/buy-tickets',{pageTitle:'Buy Tickets | PrizeMania',draw,maxQuantity:ticketService.MAX_QUANTITY});}catch(e){next(e);}}
async function purchase(req,res,next){try{const result=await ticketService.purchaseTickets({userId:req.session.user.id,drawId:Number(req.body.drawId),quantity:req.body.quantity});req.flash('success',`Purchase complete. Your ticket numbers: ${result.numbers.join(', ')}`);res.redirect('/tickets');}catch(e){if(e.status&&e.status<500){req.flash('error',e.message);return res.redirect('/tickets/buy');}next(e);}}
module.exports={showPurchase,purchase};
