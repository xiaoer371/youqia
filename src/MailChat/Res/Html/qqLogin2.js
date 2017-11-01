// 点击一键开启  帮助按钮
function helpClick (){
    var x =document.getElementById('mainFrame');
    var y =  x.contentWindow.document.getElementById('div_imap_smtp');
    var z = y.getElementsByTagName('a')[0];
    var e = x.contentWindow.document.getElementsByClassName('infobar_tip')[0];
    var f = e.getElementsByTagName('a')[1];
    if(z.textContent =='开启'){
        z.onclick();
    }else
    {
        f.onclick()
    };
};

// 调整确认提示框坐标
function resetFrame (){

    var metaTag = document.createElement('meta');
    metaTag.name = 'viewport';
    metaTag.content = 'width=device-width,initial-scale = 1.4,minimum-scale =1.4 maximum-scale=2.0,user-scalable=yes';
    document.getElementById('security-dialog_QMDialog').appendChild(metaTag);
    document.getElementById('security-dialog_QMDialog').style.left = 10 + 'px';
    document.getElementById('security-dialog_QMDialog').style.top = 100 + 'px';

};

// 获取授权码
function jsGetAuth(){
    var x = document.getElementsByClassName('securePwd_cnt_left_num')[0];
    var y = x.getElementsByTagName('span');
    var url ='';
    for(var i=0;i<y.length;i++){
        url = url + y[i].textContent;
    };
    return url;
};

// 检查是不是刚注册不到14天用户 (ps:你的QQ邮箱激活时间不满14天，故暂时无法设置。2016年11月9日(星期三) 下午5:27 后可设置此功能。)
function checkIsNewAccount (){
    var x = document.getElementById('mainFrame');
    var y = x.contentWindow.document.getElementsByClassName('infobar infobar_tip')[0];
    var z = y.textContent;
    return z;
};


function callObjc(url){
    var iframe = document.createElement('IFRAME');
    iframe.setAttribute('src', url);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};

function listenerCallBak (){
    var password = document.getElementById('pwd').value;
//    alert(password);
    var url = 'https://qq.com/?password=' + password;
    callObjc(url);
};
                        
function addLoginListener()
{
    var btn = document.getElementById('submitBtn');;
    btn.addEventListener('click',listenerCallBak,false);
};


