const { Storage } = require('@google-cloud/storage');

const storage = new Storage({
  projectId: process.env.GCP_PROJECT_ID,
  credentials: {
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  },
});

const bucket = storage.bucket(process.env.GCS_BUCKET_NAME);

async function uploadBase64(filename, base64Data, contentType) {
  const buffer = Buffer.from(base64Data, 'base64');
  const file = bucket.file(filename);
  await file.save(buffer, {
    metadata: { contentType },
    public: true,
    resumable: false,
  });
  return `https://storage.googleapis.com/${process.env.GCS_BUCKET_NAME}/${filename}`;
}

module.exports = { bucket, uploadBase64 };
