
// Call objective c. url format :  ios:function:params
function callObjc(url){
    console.log("callObjc = " + url);
    var iframe = document.createElement('IFRAME');
    iframe.setAttribute('src', url);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};

// Get pc mail url
function gotoPCMail() {
    var x = document.getElementsByClassName('qm_footer_links')[0];
    var y =  x.getElementsByTagName('a')[2];
    y.click();
};

//get pc mail setting url
function gotoSetting(){
       var str = document.getElementById('frame_html_setting').href;
       str = str.replace('setting1','setting4');
       document.getElementById('frame_html_setting').href =str;
       document.getElementById('frame_html_setting').click();
};

function disableADPage() {
    document.getElementsByClassName('enter_mail_button_td')[0].getElementsByTagName('a')[0].click();
}

// 点击一键开启  帮助按钮
function helpClick (){
    var x =document.getElementById('mainFrame');
    var y =  x.contentWindow.document.getElementById('div_imap_smtp');
    var z = y.getElementsByTagName('a')[0];
    var e = x.contentWindow.document.getElementsByClassName('infobar_tip')[0];
    var f;
    if(e){
        f = e.getElementsByTagName('a')[1];
    }
    if(z.textContent =='开启'){
        z.onclick();
    }else
    {
        f.onclick()
    };
    if ((!y && typeof(y)!='undefined' && y!=0)||(!e && typeof(e)!='undefined' && e!=0)){
        return 'false';
    }else{
        return 'true';
    }
};

// 调整确认提示框坐标
function resetFrame (){
    var metaTag = document.createElement('meta');
    metaTag.name = 'viewport';
    metaTag.content = 'width=device-width,initial-scale = 1.4,minimum-scale =1.4 maximum-scale=2.0,user-scalable=yes';
    document.getElementById('security-dialog_QMDialog').appendChild(metaTag);
    document.getElementById('security-dialog_QMDialog').style.left = 10 + 'px';
    document.getElementById('security-dialog_QMDialog').style.top = 100 + 'px';
    
    hiddenTheCloseBtn();
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



function listenerCallBak (){
    var password = document.getElementById('pwd').value;
    var url = 'ios:password:' + password;
    callObjc(url);
};

//  监听独立密码登录按钮事件
function addLoginListener()
{
    var btn = document.getElementById('submitBtn');
    if (btn) {
        btn.addEventListener('click',listenerCallBak,false);
    }
};

//屏蔽关闭按钮
function hiddenTheCloseBtn(){
    var btn = document.getElementById('security-dialog_QMDialog__closebtn_');
    if(btn){
        btn.hidden = true;
    }
};

function listenerGoCallBak (){
    var password = document.getElementById('u').value;
    var url = 'ios:go:' + password;
    callObjc(url);
};

//  监听密码登录按钮事件
function addLoginGoListener()
{
    var btn = document.getElementById('go');
    if (btn) {
        btn.addEventListener('click',listenerGoCallBak,false);
    }
};

function listenerCloseCallBack(){
    var password = 'close';
    var url = 'ios:close:' + password;
    callObjc(url);
};

// 监听提示框按钮事件
function addCloseListener()
{
    var btn = document.getElementById('security-dialog_QMDialog__closebtn_');
    if(btn){
        btn.addEventListener('click',listenerCloseCallBack,false);
    }
};


function startCheckAuthCode(){
    var intervalTimer = setInterval(function(){
        console.log("check auth code interval");
        var authCodeArray = document.getElementsByClassName('securePwd_cnt_left_num');
        if (authCodeArray.length > 0) {
            clearInterval(intervalTimer);
            var codeElmt = authCodeArray[0].getElementsByTagName('span');
            var authCode = '';
            for (var i = 0; i < codeElmt.length; i++) {
                var element = codeElmt[i];
                authCode += element.textContent;
            }
            var url = "ios:authcode:" + authCode;
            callObjc(url);
        }                      
    },1000);
}

// 执行方法
/// 监听密码登录
addLoginGoListener();
/// 监听独立登录
addLoginListener();
/// 监听提示框关闭按钮
addCloseListener();


