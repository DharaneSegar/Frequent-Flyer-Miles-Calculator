import ballerina/http;
import ballerina/jwt;
import ballerina/io;

const string DEFAULT_USER = "default";

service /airways on new http:Listener(9092) {

    resource function get frequentMiles/[string actualMiles](http:Headers headers) returns float|http:BadRequest|error {
        string|error jwtAssertion = headers.getHeader("x-jwt-assertion");
        io:println(jwtAssertion);
        if (jwtAssertion is error) {
            http:BadRequest badRequest = {
                body: {
                    "error": "Bad Request",
                    "error_description": "Error while getting the JWT token"
                }
            };
            return badRequest;
        }
        [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwtAssertion);
        json user = payload.toJson();
        string milesTier = (check user.milesTier).toString();

        float multiplier = 1.0; // Default multiplier for Silver

        if milesTier.equalsIgnoreCaseAscii("Platinum") {
            multiplier = 3.0;

        }

        else if milesTier.equalsIgnoreCaseAscii("Gold") {
            multiplier = 2.0;

        }

        float miles = check float:fromString(actualMiles);

        return multiplier * miles;

    }
}

