#!/bin/sh

#validate comments and conditional execution operators
/bin/true && echo first && /bin/false || echo after-false
/bin/false && echo unreachable-and
/bin/false || echo fallback-two
/bin/true || echo unreachable-or
echo inline #inline comment at end of command
   #comment with leading spaces
