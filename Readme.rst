Intro
=====

This is an attempt to define the rules for how we will manage cloud first
applications.

Rules of the game
-----------------

These are the guidelines we should use to judge how we deploy and maintain cloud
first applications.

  * Is everything code?

    * do we store code in a revision control system?

      * is that revision control system git?

  * How do we create infrastructure and applications?

    * does code define all infrastructure and applications?
    * is the creation and configuration of infrastructure driven by continuous
      integration and continuous delivery (CI/CD)?
    
  * How do we enforce use of cloud services as the first choice? 

  * How do we manage identity and access?

    * is iam based on our existing Active Directory?
    * do we enforce federated access to our cloud infrastructure?
    * do we enforce mfa?

  * How do we do security?

    * do we have a security policy in place?
    * do we regularly check our services for security compliance?
    * is the state of security compliance visible?

  * How do we survive an audit?

    * what is everything we need for an audit?
    * do we have a record of everything we need for an audit?
    * how long to retain these records?
    * do we always know what/who/when change occurs?

  * Are we robust?

    * do we have single points of failure?
    * can we recover from system failures and how long does it take?

  * How do we scale?

    * can cloud first applications respond to variable load by scaling in
      proportion to demand?
    * can we manage cloud compute environments for all our applications and
      customers?
    * are cloud first applications easy to maintain by customers?
    * are cloud first applications cost effective?

  * Do we know what we're doing?

    * how do we view the configuration, logs and metrics of applications,
      systems and services?
    * how can applications, systems and services tell us when they're working
      or not?
    * how do we document applications, systems and services?
    * how can you view cost?

  * Do these set of rules create an environment you would want to work in?

    * do devs people like it?
    * do ops people like it?
    * do sec people like it?
    * do managers like it?
    * will it be easy to hire a competent dev/sec/ops/manager to work in this
      enviroment?

      * would you would want to work with this dev/sec/ops/manager?
