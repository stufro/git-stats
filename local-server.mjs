import fetch from "node-fetch";
import dotenv from "dotenv";
import express from "express"
dotenv.config();
const app = express();
const port = 3000;

app.get('/user/:name', async (req, res) => {
  var response = await fetch(`http://api.github.com/users/${req.params.name}`);
  var data = await response.json();
  res.status(response.status).send(data);
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
})
