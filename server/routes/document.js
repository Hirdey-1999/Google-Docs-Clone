const express = require('express');

const Document = require('../models/document-models.js');

const DocumentRouter = express.Router();

const auth = require('../middleware/auth.js');

DocumentRouter.post('/doc/create', auth, async (req,res)=> {
    try {
        const {createdAt} = req.body;
        let document = new Document({
            uid: req.user,
            title: 'Untitled Document',
            createdAt, 
        });
        document = await document.save();
        res.json(document);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

DocumentRouter.get('/doc/me', auth, async (req,res)=> {
    try {
        let documents = await Document.find({uid: req.user});
        res.json(documents);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});

DocumentRouter.post('/doc/title', auth, async (req,res)=> {
    try {
        const {id,title} = req.body;
        const document = await Document.findByIdAndUpdate(id, {title});
        res.json(document);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
})

DocumentRouter.get('/doc/:id', auth, async (req,res)=> {
    try {
        let documents = await Document.findById(req.params.id);
        res.json(documents);
    } catch (error) {
        res.status(500).json({error: error.message});
    }
});
module.exports = DocumentRouter;
