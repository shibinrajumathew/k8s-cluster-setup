// src/App.js
import React, { useState } from "react";
import axios from "axios";

function App() {
  const [response, setResponse] = useState("");

  const handleRequest = (endpoint) => {
    const host = process.env.MS_HOST || "http://localhost:8000/";
    console.log("host name::::", host);
    axios({
      method: endpoint.method,
      url: `${host}api${endpoint.path}`,
      headers: {
        accesstoken: process.env.REACT_APP_ACCESSTOKEN,
      },
    })
      .then((res) => setResponse(res.data.operation))
      .catch((err) => console.error(err));
  };

  const endpoints = [
    { name: "Create", path: "/create", method: "post" },
    { name: "Read", path: "/read", method: "get" },
    { name: "Update", path: "/update", method: "put" },
    { name: "Delete", path: "/delete", method: "delete" },
  ];

  return (
    <div className="App">
      <h1>React and Node CRUD API</h1>
      {endpoints.map((endpoint) => (
        <button key={endpoint.name} onClick={() => handleRequest(endpoint)}>
          {endpoint.name}
        </button>
      ))}
      <p>Response: {response}</p>
    </div>
  );
}

export default App;
