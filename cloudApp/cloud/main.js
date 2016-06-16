Parse.Cloud.define("email", function(request, response) {
var Mandrill = require('mandrill');
Mandrill.initialize('vPIT4Hx_NM_rciNztmNOxA');
Mandrill.sendEmail({
    message: {
    	html:request.params.htmlCode,
        text:request.params.text,
        subject: request.params.username,
        from_email: "michael@dote.space",
        from_name: "The Dote App",
        to: [
            {
                email:request.params.email,
                name: "Pandemos UserName"
            }
        ]
    },
    async: true
},{
    success: function(httpResponse) {
        response.success("email sent");
    },
    error: function(httpResponse) {
        response.error("Something went wrong");
    }
}
);
});



//add match relation
Parse.Cloud.define("addMatchToMatchRelation", function(request, response) {
  
    Parse.Cloud.useMasterKey();
  
    var matchRequestId = request.params.matchRequest;
    var query = new Parse.Query("MatchRequest");
    console.log("step 1")
    //get the friend request object
    query.get(matchRequestId, {
  
        success: function(matchRequest) {
  
            //get the user the request was from
            //something else
            var fromUser = matchRequest.get("fromUser");
            //get the user the request is to
            var toUser = matchRequest.get("toUser");
  
            var relation = fromUser.relation("match");
            //add the user the request was to (the accepting user) to the fromUsers friends
            relation.add(toUser);
  
            //save the fromUser
            fromUser.save(null, {
  
                success: function() {
  
                    //saved the user, now edit the request status and save it
                    //matchRequest.set("status", "pending");
                    matchRequest.save(null, {
  
                        success: function() {
  
                            response.success("saved relation and updated matchRequest");
                        }, 
  
                        error: function(error) {
  
                            response.error("Error 1");
                        }
  
                    });
  
                },
  
                error: function(error) {
  
                 response.error("Error 2");
  
                }
  
            });
  
        },
  
        error: function(error) {
  
            response.error("error 3");
  
        }
  
    });
  
});




//layer funcitonality
var fs = require('fs');
var layer = require('cloud/layer-parse-module/layer-module.js');
 
var layerProviderID = '8b0c63ce-0cab-11e6-b294-424d000047e5';
var layerKeyID = '3b495e9c-0d72-11e6-aa51-a8ea00006b62';
var privateKey = fs.readFileSync('cloud/layer-parse-module/keys/layer-key.js');
 
var twilio = require("twilio");
twilio.initialize("AC42c81cfeff3ee6039f1dbd613420c267","04ea44eb31ef8c7456453b7ced5a3fb6");
 
layer.initialize(layerProviderID, layerKeyID, privateKey);
 
Parse.Cloud.define("generateToken", function(request, response) {
    var userID = request.params.userID;
    var nonce = request.params.nonce;
    if (!userID) throw new Error('Missing userID parameter');
    if (!nonce) throw new Error('Missing nonce parameter');
        response.success(layer.layerIdentityToken(userID, nonce));
});