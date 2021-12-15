# COM03-AWS200
Second 100DaysOfCloud project developed in Terraform

Objectives achieved:

- Create a Launch Configuration
  - It was created using the resource "aws_launch_template"
- Create an Auto Scaling Group with a minimum of two and a maximum of five EC2 instances
  - It was created using the resource "aws_autoscaling_group", I used a minimum of three instances.
- Terminate one instance manually
  - It was done by the console.
  - After the ASG is in place, increase the desired number of instances to three
- It wasn't necessary because it was done through the code.
  - Delete all the resources you created
- It was done with the "terraform destroy" command.
