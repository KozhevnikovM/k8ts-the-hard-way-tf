
resource "aws_lb" "kubernetes" {
  name               = "kubernetes"
  subnets            = [aws_subnet.kubernetes.id]
  internal           = false
  load_balancer_type = "network"
}

resource "aws_lb_target_group" "kubernetes" {
  name        = "kubernetes"
  target_type = "ip"
  protocol    = "TCP"
  port        = "6443"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "kubernetes" {
  count = length(aws_instance.controller)

  target_group_arn = aws_lb_target_group.kubernetes.arn
  target_id        = aws_instance.controller[count.index].id

}

resource "aws_lb_listener" "kubernetes" {
  load_balancer_arn = aws_lb.kubernetes.arn
  protocol          = "tcp"
  port              = 443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubernetes.arn
  }

}