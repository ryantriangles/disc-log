const express = require('express');
const app = express();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('discs.sqlite3');

app.use((req, res, next) => {
	res.header('Access-Control-Allow-Origin', '*');
	res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
	next();
});

app.get('/list', (req, res, next) => {
	db.all('select owner, title, format, rowid as id, completed, date from discs order by date desc', (err, rows) => {
		console.log("DB hit");
		res.send(rows);
	});
});

app.post('/insert', (req, res) => {
	let query =
		"INSERT INTO DISCS (owner, format, title, date, completed) VALUES ($owner, $format, $title, $date, $completed)";
	db.run(query, [ req.body.owner, req.body.format, req.body.title, parseInt(new Date().getTime()/1000), 0], function (err) {
		if (err) {
			console.log("Error!");
			res.json(0); // Indicates an error.
		} else {
			console.log("Added " + req.body.title);
			res.json(this.lastID);
		}
	});
});

app.post('/delete', (req, res) => {
	let query = "DELETE FROM discs WHERE rowid = ?";
	db.run(query, [req.body.id], function(err) {
		if (err) {
			console.log(err);
			res.json(0);
		} else {
			console.log("Deleted " + req.body.id);
			res.json(req.body.id);
		}
	});
});

app.post('/edit', (req, res) => {
	let query = "UPDATE discs SET owner = $owner, format = $format, title = $title, completed = $completed, date = $date WHERE rowid = $id";
	db.run(query, {
		$id: req.body.id,
		$title: req.body.title,
		$owner: req.body.owner,
		$completed: req.body.completed == "true" ? 1 : 0,
		$format: req.body.format,
		$date: parseInt(new Date().getTime()/1000)
	}, function (err) {
		if (err) {
			console.log(err);
			res.json(0); // Indicates an error.
		} else {
			res.json(1); // Indicates success.
		}
	});
});

app.listen(4712);
