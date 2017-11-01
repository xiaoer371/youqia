//
//  MCUmengManager.h
//  NPushMail
//
//  Created by zhang on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

//登录
//登录类型
static NSString *mc_login            = @"login_type";       // 登录类型


static NSString *mc_login_regist     = @"login_regist";
static NSString *mc_login_forget     = @"login_forget";
static NSString *mc_login_helper     = @"login_helper";


//消息
static NSString *mc_im_sendoa     = @"im_sendoa";
static NSString *mc_im_sendchat   = @"im_sendchat";
static NSString *mc_im_sendImage  = @"im_sendImage";
static NSString *mc_im_takePhoto  = @"im_takePhoto";
static NSString *mc_im_sendfile     = @"im_sendfile";
static NSString *mc_im_sendvoice     = @"im_sendvoice";
static NSString *mc_im_disturb     = @"im_disturb";
static NSString *mc_im_top      = @"im_top";
static NSString *mc_im_clear     = @"im_clear";
static NSString *mc_im_addMember     = @"im_addMember";
static NSString *mc_im_exit     = @"im_exit";

//邮件
static NSString *mc_mail_write              = @"mail_write";
static NSString *mc_mail_send               = @"mail_send"; //邮件发送成功率
//文件夹
static NSString *mc_mail_folder             = @"mail_folder";
static NSString *mc_mail_folder_SmartToInbox = @"SmartToInbox";
static NSString *mc_mail_folder_InboxToSmart = @"InboxToSmart";
static NSString *mc_mail_folder_inbox       = @"Inbox";
static NSString *mc_mail_folder_smart       = @"Smart";
static NSString *mc_mail_folder_other       = @"Other";
//邮件列表查找
static NSString *mc_mail_search_all         = @"mail_search_all";
static NSString *mc_mail_search_subject     = @"mail_search_subject";
static NSString *mc_mail_search_sender      = @"mail_search_sender";
static NSString *mc_mail_search_receiver    = @"mail_search_receiver";
// 进入编辑状态
static NSString *mc_mail_edit_read          = @"mail_edit_read";
static NSString *mc_mail_edit_star          = @"mail_edit_star";
static NSString *mc_mail_edit_move          = @"mail_edit_move";
static NSString *mc_mail_edit_delete        = @"mail_edit_delete";
// 筛选
static NSString *mc_mail_all_all            = @"mail_all_all";
static NSString *mc_mail_all_read           = @"mail_all_read";
static NSString *mc_mail_all_star           = @"mail_all_start";

static NSString *mc_mail_list_move          = @"mail_list_move";
static NSString *mc_mail_list_star          = @"mail_list_start";
static NSString *mc_mail_list_delete        = @"mail_list_delete";
static NSString *mc_mail_list_read          = @"mail_list_read";
static NSString *mc_mail_list_view          = @"mail_list_view";
static NSString *mc_mail_list_refresh       = @"mail_list_refresh";

static NSString *mc_mail_detail_star        = @"mail_datail_start";
static NSString *mc_mail_detail_im_single   = @"mail_datail_im_single";
static NSString *mc_mail_detail_im_group    = @"mail_datail_im_group";
static NSString *mc_mail_detail_reall       = @"mail_datail_reall";
static NSString *mc_mail_detail_re          = @"mail_datail_re";
static NSString *mc_mail_detail_forward     = @"mail_datail_forward";
static NSString *mc_mail_detail_re_att      = @"mail_datail_re_att";
static NSString *mc_mail_detail_re_noatt    = @"mail_datail_re_noatt";
static NSString *mc_mail_detail_more_move   = @"mail_datail_more_move";
static NSString *mc_mail_detail_more_delete = @"mail_datail_more_delete";
static NSString *mc_mail_detail_more_read   = @"mail_datail_more_read";
static NSString *mc_mail_detail_backlog     = @"mail_detail_backlog";


static NSString *mc_mail_detail_write_image     = @"mail_datail_write_image";
static NSString *mc_mail_detail_write_takephoto = @"mail_datail_write_takephoto";
static NSString *mc_mail_detail_write_file      = @"mail_datail_write_file";
static NSString *mc_mail_detail_write_bcc       = @"mail_datail_write_bb";
static NSString *mc_mail_detail_write_cc        = @"mail_datail_write_cc";
static NSString *mc_mail_detail_write_contact   = @"mail_datail_write_contact";
static NSString *mc_mail_to_contact       = @"mail_to_contactInfo"; //邮件列表联系人
//重要邮件
static NSString *mc_mail_important = @"mail_list_impt";
static NSString *mc_mail_important_count = @"count";
static NSString *mc_mail_important_unread_count = @"impt_unread_count";
static NSString *mc_mail_important_view = @"view";
static NSString *mc_mail_important_delete = @"delete";
static NSString *mc_mail_important_set_important = @"important";
static NSString *mc_mail_important_set_unimportant = @"unimportant";
static NSString *mc_mail_important_read = @"read";
static NSString *mc_mail_important_unread = @"unread";
static NSString *mc_mail_important_backlog = @"backlog";
static NSString *mc_mail_important_unBacklog = @"unBacklog";

//待办
static NSString *mc_mail_backlog = @"mail_backlog";
static NSString *mc_mail_backlog_vipListBacklog = @"mail_backlog_vipListBacklog";
static NSString *mc_mail_backlog_vipListUnBacklog = @"mail_backlog_vipListUnBacklog";
static NSString *mc_mail_backlog_normalListBacklog = @"mail_backlog_normalListBacklog";
static NSString *mc_mail_backlog_normalListUnBacklog = @"mail_backlog_normalListUnBacklog";
static NSString *mc_mail_backlog_detailBacklog = @"mail_backlog_detailBacklog";
static NSString *mc_mail_backlog_detailUnBacklog = @"mail_backlog_detailUnBacklog";

//联系人
static NSString *mc_contact_search        = @"contact_search";
static NSString *mc_contact_enterprise    = @"contact_enterprise";
static NSString *mc_contact_youqia    = @"contact_youqia";
static NSString *mc_contact_group    = @"contact_group";
static NSString *mc_contact_info_write    = @"contact_info_write";
static NSString *mc_contact_info_im    = @"contact_info_im";
static NSString *mc_contact_info_start    = @"contact_info_start";
static NSString *mc_contact_info_mail = @"contac_info_mail";
static NSString *mc_contact_delete    = @"contact_delete";

//我
static NSString *mc_me_change    = @"me_change";
static NSString *mc_me_add   = @"me_add";
static NSString *mc_me_account_head   = @"me_account_head";
static NSString *mc_me_account_name   = @"me_account_name";
static NSString *mc_me_account_cc   = @"me_account_cc";
static NSString *mc_me_account_server   = @"me_account_server";
static NSString *mc_me_account_exit   = @"me_account_exit";
static NSString *mc_me_notice   = @"me_notice";
static NSString *mc_me_signature_unify   = @"me_signature_unify";
static NSString *mc_me_signature_divide   = @"me_signature_divide";
static NSString *mc_me_ps_fingerprint   = @"me_ps_fingerprint";
static NSString *mc_me_ps_gestures   = @"me_ps_gestures";
static NSString *mc_me_mailhead   = @"me_mailhead";
static NSString *mc_me_file_im   = @"me_file_im";
static NSString *mc_me_file_mail   = @"me_file_mail";
static NSString *mc_me_file_delete   = @"me_file_delete";
static NSString *mc_me_clear   = @"me_clear";
static NSString *mc_me_feedback   = @"me_feedback";
static NSString *mc_me_feedbackall   = @"me_feedbackall";
static NSString *mc_me_score   = @"me_score";
//反馈
static NSString *mc_praise = @"app_praise";
static NSString *mc_praise_like = @"app_praise_like";
static NSString *mc_praise_unLike = @"app_praise_unLike";
static NSString *mc_praise_feedback = @"app_praise_feedback";
static NSString *mc_praise_star = @"app_praise_star";
static NSString *mc_praise_unNote = @"app_praise_unNote";
static NSString *mc_praise_35UnNote = @"app_praise_35UnNote";
static NSString *mc_praise_35UserStar = @"app_praise_35UserStar";

//qq 登录事件统计 漏斗统计
static NSString *mc_qq_login       = @"login_qq";
static NSString *mc_qq_loginpsd    = @"login_psd";
static NSString *mc_qq_loginSuc    = @"login_qq_success";
static NSString *mc_qq_loginfail   = @"login_qq_fail";
static NSString *mc_qq_loginAuth   = @"login_qq_auth";
static NSString *mc_qq_webPsd      = @"login_qq_web_login";
static NSString *mc_qq_loginSMS    = @"login_sms";
static NSString *mc_qq_loginBack   = @"login_back";

/*
 *  5.6 新增统计
 *  有子事件的 如：推送：
 *  eg： [MCUmengManager addEventWithKey:mc_push attributes:@{@"type" : @"delete"}];
 *  eg： [MCUmengManager addEventWithKey:mc_push attributes:@{@"type" : @"read"}];
 */
static NSString *mc_push               = @"mc_push";   //推送
static NSString *mc_push_mailTrash     = @"push_mailTrash";
static NSString *mc_push_mailRead      = @"push_mailRead";

static NSString *mc_mail_adjust        = @"mail_adjust";  //读信页面字体

@interface MCUmengManager : NSObject

//添加友盟事件
+ (void)addEventWithKey:(NSString*)key;

+ (void)addEventWithKey:(NSString*)key  label:(NSString *)string;


/**
 重要邮件结构化事件

 @param event 时间名称
 */
+ (void)importantEvent:(NSString *)event;
+ (void)folderChangeEvent:(NSString*)event;
+ (void)pushEvent:(NSString*)event;
+ (void)praiseEvent:(NSString*)event;
+ (void)backlogEvent:(NSString*)event;


+ (void)addEventWithKey:(NSString *)key attributes:(NSDictionary *)attributes;

@end
