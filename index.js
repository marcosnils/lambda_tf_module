const figlet = require('figlet');

exports.test =  async function(event, context) {
  return figlet.textSync('Hello London HUG!!');
}
