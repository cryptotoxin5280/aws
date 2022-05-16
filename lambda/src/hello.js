const AWS = require('aws-sdk');

const s3 = new AWS.S3({
    endpoint: new AWS.Endpoint('host.docker.internal:4566')
});

exports.handler = (async (event, context) => {
    console.log('EVENT: \n' + JSON.stringify(event, null, 2));
    const buckets = await s3.listBuckets().promise();
    message = `S3 Buckets: ${JSON.stringify(buckets)}`
    return {
        statusCode: 200,
        body: {
            message: message
        }
    }
});
