Parse.Cloud.define("email", function(request, response) {
var Mandrill = require('mandrill');
Mandrill.initialize('vPIT4Hx_NM_rciNztmNOxA');
Mandrill.sendEmail({
    message: {
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