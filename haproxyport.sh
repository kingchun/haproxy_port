#!/bin/bash
#修改配置
#用于haproxy实现tcp端口转发send-proxy参数为连IP一起发送不要可以删除
#date Sun Feb 21 19:50:34 CST 2021
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

conf_mo(){
cat <<EOF> /etc/haproxy/haproxy.cfg
global
        ulimit-n  51200

defaults
        log global
        mode    tcp
        option  dontlognull
        contimeout 1000
        clitimeout 150000
        srvtimeout 150000
EOF
}

conf_in(){
echo -n "请输入域名:"                   
read  domain 
echo -n "请输监听本地入端口:"                   
read  port
echo -n "请输远程服务器端口:"                   
read  port2
cat <<EOF>> /etc/haproxy/haproxy.cfg
frontend ss-in${port}
        bind *:${port}
        default_backend ss-out

backend ss-out${port}
        server server1 ${domain}:${port2} send-proxy

##0.0.0.0:${port}------->>${domain}:${port2}

EOF
service haproxy reload
}

conf_ou(){
arr1=(`cat /etc/haproxy/haproxy.cfg |grep "ss-in${prot}" -n |awk -F: '{print $1}'`)
if [ $arr1 == 0 ]
then
    echo "没有找到端口哦"
	exit 1
else 
	echo "找到端口"
	sed -i '${arr1},$[arr1+8]d'
fi

service haproxy reload
}

haproxy_install(){
haproxy -v
if [ $? -eq  0 ]; then
	            echo "检查到haproxy已安装!"
	    else
				echo "检查到haproxy没有安装现在开始安装!"
				yum install haproxy -y||apt install haproxy -y
				confmo
fi
}

conf_look{
cat /etc/haproxy/haproxy.cfg |grep "##"
}

conf_cp(){
cp /etc/haproxy/haproxy.cfg ~/haproxy.cfg.back
}

echo -e "\033[0;32m ******************** \033[0m"
echo -e "\033[0;32m **haproxy部署脚本** \033[0m"
echo -e "\033[0;32m ******************** \033[0m"
echo -e "\033[0;32m 1.查看配置 \033[0m"
echo -e "\033[0;32m 2.增加转发 \033[0m"
echo -e "\033[0;32m 3.删除转发 \033[0m"
echo -e "\033[0;32m 4.安装haproxy \033[0m"
echo -e "\033[0;32m 5.备份haproxy配置 \033[0m"
echo -e "\033[0;32m 6.还原haproxy配置！！！不要乱用 \033[0m"
echo -e "\033[0;32m 查看状态请输入7 \033[0m"
read  -p "请输入选项:" xuanxiang
###根据选择执行那个函数###
case $xuanxiang in
 "1")
conf_look
  ;;
 "2")
conf_in
  ;;
 "3")
conf_ou
  ;;
 "4")
haproxy_install
conf_mo
  ;;
  "5")
conf_cp
  ;;
 "6")
conf_mo
  ;;
  "7")
systemctl status haproxy
  ;;
 *)
  echo -e "\033[0;31m 输入有毛病呀老铁 \033[0m"
  ;;
esac