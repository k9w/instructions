# My journey with AWS

[Amazon Web Services](https://aws.amazon.com) is a Top 10 ranked cloud
provider in revenue, customers and deployments.

They have [extensive documentation](https://docs.aws.amazon.com). This
article outlines my personal journey with AWS, a log so to speak.

I stated the AWS portion of my Amazon account a few years ago (2018?)
and used up my 1 year free tier without significant usage. On July 4th
2022, I launched an OpenSUSE TumbleWeed instance created in the AMI
marketplace from Nov 2021. I updated and rebooted it monthly and didn't
run any hosted services on it.

The EC2 instance type I used was: t3a.nano

This created a storage volume of 10GB. I had a second 10GB volume,
probably from a previous instance attempt I had.

On Dec 10 2022, I applied updates and rebooted it. From then on, it
wasn't reachable by ssh, ping, aws consle, aws serial console.

It too forever to stop the instance.

The docs said to check the status with aws cli. The docs cautioned
against using the AWS account root user for CLI access.

So I decided now is the time to learn Identity Access Management, create
an admin user, and a regular user.

- Use the root account only for what no other account can do.

- Use the admin account for administrative tasks, including creating and
  managing a regular user.

- Use a regular, unprivileged IAM account for all allowed actions on aws 
  console and aws cli, including runing all instances as that user.


The problem to solve:

Instance is not reachable after reboot, takes forever to reboot or stop
from the console, and gets stuck in 'stopping' status. Tne links below
indicate it could be a problem with the physical host and to check the
instance with the aws cli.

<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/TroubleshootingInstancesStopping.html>
<https://aws.amazon.com/premiumsupport/knowledge-center/ec2-instance-stuck-stopping-state>

<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-serial-console.html>

I've decided to delete my instance and two volumes and only start using
resources once I've setup user accounts to do so.



