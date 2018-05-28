Amazon Web Services
===================

Amazon Web Services (AWS_) is a global compute services provider

    .. _AWS: https://aws.amazon.com/

How
---

We should adhere to the WellArchitected_ frame work provided by AWS.

    .. _WellArchitected: https://aws.amazon.com/architecture/well-architected/

Where
-----

AWS has Regions_ distributed across the globe. Our default region is us-west-2
(oregon) because it's cheap and fast. us-east-1 is our second choice because it
always has the services running in us-west-2. We typically try to use all
availibility zones within a region for durability of applications.

    .. _Regions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html

What
----

.. note:: EVERYTHING is code!   Say it again! EVERYTHING is code!

Developer Tools
^^^^^^^^^^^^^^^

  * Use the Codecommit_ Git_ service provided by AWS 

    .. _Codecommit: https://aws.amazon.com/codecommit/
    .. _Git: https://git-scm.com/

  * Use the native AWS continuous integration continuous delivery services
    Codepipeline_ and Codebuild_

    .. _Codepipeline: https://aws.amazon.com/codepipeline/
    .. _Codebuild: https://aws.amazon.com/codebuild/

  * Use the online AWS ide service Cloud9_

    .. _Cloud9: https://aws.amazon.com/cloud9/

Management
^^^^^^^^^^

  * Use the free Cloudformation_ service provided by AWS 

  .. _Cloudformation: https://aws.amazon.com/cloudformation/

    * Cloudformation templates (cft) build aws infrastructure as stacks

      * A few things can not be created via cft, but most everything can

        * use python/boto for these exceptions

    * Use python code to create cft with Troposphere_

    .. _Troposphere: https://github.com/cloudtools/troposphere

    * Use python code to orchestrate cft creation and deployment with Sceptre_

    .. _Sceptre: https://sceptre.cloudreach.com/latest/docs/index.html

    * Cloudformation stacks should have useful outputs

  * Log all AWS api calls with AWS service Cloudtrail_

    .. _Cloudtrail: https://aws.amazon.com/cloudtrail/

  * If it moves log it! Log everything to AWS service Cloudwatch_ or S3_

    .. _Cloudwatch: https://aws.amazon.com/cloudwatch/
    .. _S3: https://aws.amazon.com/s3/

  * Record and enforce configuration state in each AWS region with the AWS
    service Config_

    .. _Config: https://aws.amazon.com/config/

  * Create accounts within AWS service Organizations_ and use
    ServiceControlPolicies_ to limit services as needed

    .. _Organizations: https://aws.amazon.com/organizations/
    .. _ServiceControlPolicies: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_about-scps.html

  * Use SystemsManager_ AWS service to manage all ec2 instances

    .. _SystemsManager: https://aws.amazon.com/systems-manager/

Networking
^^^^^^^^^^


  * Record network traffic in every VPC with the AWS service Flowlogs_

    .. _Flowlogs: https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/flow-logs.html

  * use AWS DNS service Route53_

  .. _Route53: https://aws.amazon.com/route53/

    * ucop-its account contains the nameserver records for devops.ucop.edu and
      universityofcalifornia.devops.ucop.edu

    * Hosted zone subdomains of devops.ucop.edu must have a NS record in ucop-its

    * Hosted zone for accounts follows .$team-$env.devops.ucop.edu convention

Security, Identity & Compliance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use native AWS security, identity and compiance services:


  * Store secrets in AWS service SecretsManager_

    .. _SecretsManager: https://aws.amazon.com/secrets-manager/

  * Analyse cloudtrail, network traffic and DNS activity with the AWS service
    Guardduty_

    .. _Guardduty: https://aws.amazon.com/guardduty/

  * Scan ec2 instances with AWS service Inspector_

    .. _Inspector: https://aws.amazon.com/inspector/

  * Scan s3 contents with Macie_

    .. _Macie: https://aws.amazon.com/macie/

  * Access to AWS should use AWS SingleSignOn_ service based on our corporate
    Active Directory service using IdentityFederation_

    .. _SingleSignOn: https://aws.amazon.com/single-sign-on/
    .. _IdentityFederation: https://aws.amazon.com/identity/federation/

  * Use the native AWS CertificateManager_ service for public and private certs

    .. _CertificateManager: https://aws.amazon.com/certificate-manager/

    * Non production application endpoints are allowed to use wildcard certificates
    * Production applications would have a dedicated cert created for $application.ucop.edu

  * Encrypt everything using AWS service KeyManagementService_ 

    .. _KeyManagementService: https://aws.amazon.com/kms/
