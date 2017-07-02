

const elastic = require('elasticsearch');
const client = new elastic.Client();
const templates = require('../config/templates.json');


function waitToElastic(callback) {
    client.ping(function(err, res) {
        if(err || !res) {
            setTimeout(() => {
                console.log("[i] continue wait to elastic");
                waitToElastic(callback);
            }, 1000);
        } else {
            callback();
        }
    });
}


console.log(templates);

waitToElastic(function() {
    client.indices.putTemplate({
        create: true,
        body: templates.logstash,
        name: "logstash"
    }, (err, res) => {
        console.log(res);
    });

    client.indices.putTemplate({
        create: true,
        body: templates.metricbeat,
        name: "metricbeat"
    }, (err, res) => {
        console.log(res);
    });

    client.indices.putTemplate({
        create: true,
        body: templates.kibana,
        name: "kibana"
    }, (err, res) => {
        console.log(res);
    });
});




