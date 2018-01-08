if Rails.env.production?
    bucket = ENV['AWS_S3_BUCKET_NAME']
    region = ENV.fetch('AWS_S3_REGION'){ 'ap-northeast-1' }

    Paperclip::Attachment.default_options.update(
        path: ':url',
        url: ':class/:id/:attachment/:style/:filename',
        storage: :fog,
        fog_credentials: {
            provider: 'AWS',
            region: region,
            use_iam_profile: true
        },
        fog_attributes: {
            cache_control: 'max-age=315576000',
            encryption: 'AES256',
            acl: 'private'
        },
        fog_host: "https://s3-#{region}.amazonaws.com/#{bucket}",
        fog_directory: bucket
    )
end
