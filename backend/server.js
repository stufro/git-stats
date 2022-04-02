'use strict';

import fetch from "node-fetch"
import dotenv from "dotenv"
import express from "express"
import serverless from "serverless-http"
import bodyParser from "body-parser"
const app = express();
const router = express.Router();

dotenv.config();

router.get('/user/:name', async (req, res) => {
  var response = await fetch(`http://api.github.com/users/${req.params.name}`, {
    headers: { "Authorization": `Basic ${process.env.GITHUB_PASSWORD}` }
  });
  var data = await response.json();
  res.status(response.status).send(data);
})

router.get('/user/:name/repos', async (req, res) => {
  var response = await fetch(`http://api.github.com/users/${req.params.name}/repos?per_page=100`, {
    headers: { "Authorization": `Basic ${process.env.GITHUB_PASSWORD}` }
  });
  var data = await response.json();
  res.status(response.status).send(data);
})

router.get('/user/:name/last_activity', async (req, res) => {
  var response = await fetch(`http://api.github.com/users/${req.params.name}/events?per_page=1`, {
    headers: { "Authorization": `Basic ${process.env.GITHUB_PASSWORD}` }
  });
  var data = await response.json();
  res.status(response.status).send(data);
})

app.use(bodyParser.json());
app.use('/.netlify/functions/server', router);

export default app;
const handler = serverless(app); 
export { handler };
