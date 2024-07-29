var createError = require("http-errors");
var express = require("express");
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");
const cors = require("cors");

var app = express();

// Use the CORS middleware
app.use(cors());
// view engine setup

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

// app.use((req, res, next) => {
//   const token = req.headers["accesstoken"];
//   if (token === ACCESS_TOKEN) {
//     next();
//   } else {
//     res.status(403).json({ message: "Forbidden" });
//   }
// });

app.get("/api", (req, res) => {
  res.send("Welcome to the API");
});

app.post("/api/create", (req, res) => {
  res.json({ operation: "create" });
});

app.get("/api/read", (req, res) => {
  res.json({ operation: "read" });
});

app.put("/api/update", (req, res) => {
  res.json({ operation: "update" });
});

app.delete("/api/delete", (req, res) => {
  res.json({ operation: "delete" });
});

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get("env") === "development" ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render("error");
});

module.exports = app;
