const express = require("express");
const User = require("../models/user-data.js");
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth.js");
const authRouter = express.Router();

authRouter.post("/api/signup", async (req, res) => {
    try {
        const {name,email} = req.body;
        let user = await User.findOne({email: email});

        if(!user){
            user = new User({
                name,
                email,
            });
            user = await user.save();
        }
        const token = jwt.sign({id: user._id}, "passwordKey");
        res.json({ user, token });
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});

authRouter.get('/', auth, async (req,res) =>{
    const user = await User.findById(req.user);
    res.json({user, token: req.token});
    console.log(req.user); 
    console.log(req.token);
});

module.exports = authRouter; 