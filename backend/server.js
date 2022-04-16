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
  var githubResponse = await githubRequest(`${req.params.name}`, res);
  res.status(githubResponse.status).send(githubResponse.data);
})

router.get('/user/:name/repos', async (req, res) => {
  var githubResponse = await githubRequest(`${req.params.name}/repos?per_page=100`, res);
  var repos = githubResponse.data

  var repos = await fetchSubsequentPages(repos, req.params.name, githubResponse.link, res)

  res.status(githubResponse.status).send(repos);
})

async function fetchSubsequentPages(results, username, link, res) {
  if (typeof link === "string" && (link.match(/<(\S+)>; rel="next"/) !== null)) {
    var newParams = link.match(/<(\S+)\>; rel="next"/)[1].split("?")[1]
    var githubResponse = await githubRequest(`${username}/repos?${newParams}`, res);
    var concatResults = results.concat(githubResponse.data)
    return await fetchSubsequentPages(concatResults, username, githubResponse.link, res)
  } else {
    return results
  }
}

router.get('/user/:name/last_activity', async (req, res) => {
  var githubResponse = await githubRequest(`${req.params.name}/events?per_page=1`, res);
  res.status(githubResponse.status).send(githubResponse.data[0] || {});
})

async function githubRequest(endpoint, res) {
  var response = await fetch(`http://api.github.com/users/${endpoint}`, {
    headers: { "Authorization": `Basic ${process.env.GITHUB_PASSWORD}` }
  });
  var data = await response.json();
  res.set('Access-Control-Allow-Origin', '*');
  return new Object({status: response.status, data: data, link: response.headers.get("link")})
}

app.use(bodyParser.json());
app.use('/.netlify/functions/server', router);
export default app;
const handler = serverless(app); 
export { handler };
