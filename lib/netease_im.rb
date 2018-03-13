require "netease_im/version"

module NeteaseIM
  class Client

    ACTION_ADD_USER = 'user/create.action'
    ACTION_GET_USER = 'user/getUinfos.action'
    ACTION_UPDATE_USER = 'user/updateUinfo.action'

    ACTION_CREATE_GROUP = 'team/create.action'
    ACTION_GET_GROUP = 'team/query.action'
    ACTION_INVITE_GROUP = 'team/add.action'
    ACTION_QUIT_GROUP = 'team/leave.action'
    ACTION_EXPEL_GROUP = 'team/kick.action'
    ACTION_DISMISS_GROUP = 'team/remove.action'
    ACTION_SET_MANAGER = 'team/addManager.action'
    ACTION_GET_MEMBERS = 'team/query.action'
    ACTION_UNSET_MANAGER = 'team/removeManager.action'
    ACTION_GET_ALL_GROUPS = 'team/joinTeams.action'
    ACTION_UPDATE_GROUP = 'team/update.action'
    ACTION_CHAHGE_OWNER = 'team/changeOwner.action'
    ACTION_SET_MEMBER_NICK = 'team/updateTeamNick.action'
    ACTION_SET_GROUP_MUTE = 'team/muteTeam.action'
    ACTION_MUTE_GROUP_MEMBER = 'team/muteTlist.action'
    ACTION_MUTE_ALL_GROUP_MEMBERS = 'team/muteTlistAll.action'
    ACTION_GET_MUTE_GROUP_MEMBERS = 'team/listTeamMute.action'

    ACTION_SEND_MSG = 'msg/sendMsg.action'
    ACTION_SEND_BATCH_MSG = 'msg/sendBatchMsg.action'
    ACTION_SEND_NOTIFICATION = 'msg/sendAttachMsg.action'
    ACTION_SEND_BATCH_NOTIFICATION = 'msg/sendBatchAttachMsg.action'

    ACTION_ADD_FRIEND = 'friend/add.action'
    ACTION_SET_FRIEND_REMARK = 'friend/update.action'
    ACTION_DELETE_FRIEND = 'friend/delete.action'
    ACTION_GET_FRIENDS = 'friend/get.action'
    ACTION_SET_SPECIAL_RELATION = 'user/setSpecialRelation.action'
    ACTION_GET_BLACKLIST_AND_MUTELIST = 'user/listBlackAndMuteList.action'
    
    def initialize(app_key = ENV['app_key'], app_secret = ENV['app_secret'])
      @version = 1.0
      @api_host = 'https://api.netease.im/nimserver/'
      @app_key = app_key
      @app_secret = app_secret
    end

    def headers
      {
        'AppKey' => @app_key,
        'Nonce' => nonce,
        'CurTime' => current_time,
        'CheckSum' => check_sum,
        'User-Agent'   => "NeteaseIMSdk/NeteaseIM-Ruby-Sdk #{RUBY_VERSION} (#{@version})",
        'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8'
      }
    end

    def nonce
      @nonce ||= SecureRandom.hex(16)
    end

    def current_time
      @current_time || Time.now.to_i.to_s
    end

    def check_sum
      Digest::SHA1.hexdigest("#{@app_secret}#{nonce}#{current_time}").downcase
    end

    def http_call(url, params)
      res = Nestful.post(url, params, {headers: headers})
      response_object(JSON.parse(res.body))
    end

    def response_object(body)
      response = Struct.new(:success, :data).new
      response.success = body['code'] == 200
      response.data = body
      response
    end

    def post(action, params)
      http_call("#{@api_host}#{action}", params)
    end

    def add_user(user_id, nickname = '', avatar_url = '')
      post( ACTION_ADD_USER, { accid: user_id, name: nickname, icon: avatar_url } )
    end

    def get_users(user_ids)
      post( ACTION_GET_USER, { accids: user_ids.to_json } )
    end

    def update_user(user_id, nickname = '', avatar_url = '')
      post( ACTION_UPDATE_USER, { accid: user_id, name: nickname, icon: avatar_url } )
    end

    def create_group(owner, group_name, members, notice = '', msg = '', magree = 0, joinmode = 0)
      post( ACTION_CREATE_GROUP, { owner: owner,
                                   tname: group_name,
                                   members: members,
                                   msg: msg,
                                   announcement: notice,
                                   magree: magree,
                                   joinmode: joinmode
                                 }
          )
    end

    def invite_group(owner, group_id, members, msg = '', magree = 0)
      post( ACTION_INVITE_GROUP, { owner: owner,
                                   tid: group_id,
                                   members: members,
                                   msg: msg,
                                   magree: magree
                                 }
          )
    end

    def expel_group(owner, group_id, member, attach = '')
      post( ACTION_EXPEL_GROUP, { owner: owner,
                                  tid: group_id,
                                  member: member,
                                  attach: attach
                                }
          )
    end

    def quit_group(group_id, member)
      post( ACTION_QUIT_GROUP, { tid: group_id, member: member } )
    end

    def dismiss_group(owner, group_id)
      post( ACTION_DISMISS_GROUP, { tid: group_id, owner: owner } )
    end

    def update_group(owner, group_id, group_name = nil, avatar_url = nil, notice = nil,
                     intro = nil, joinmode = 0, custom = nil, beinvitemode = 1,
                     invitemode = 1, uptinfomode = 1, upcustommode = 1)

      options = { owner: owner,
                  group_id: group_id,
                  joinmode: joinmode,
                  custom: custom,
                  beinvitemode: beinvitemode,
                  invitemode: invitemode,
                  uptinfomode: uptinfomode,
                  upcustommode: upcustommode
                }
      options[:group_name] = group_name unless group_name.nil?
      options[:avatar_url] = avatar_url unless avatar_url.nil?
      options[:notice] = notice unless notice.nil?
      options[:intro] = intro unless intro.nil?
      post( ACTION_UPDATE_GROUP, options )
    end

    def get_group(group_id)
      post( ACTION_GET_GROUP, { tids: [group_id].to_json, ope: 0 } )
    end

    def get_group_members(group_ids)
      post( ACTION_GET_MEMBERS, { tids: group_ids.to_json, ope: 1 } )
    end

    def get_all_group(user_id)
      post( ACTION_GET_ALL_GROUPS, { accid: user_id } )
    end

    def set_member_nick(owner, group_id, user_id, nickname)
      post( ACTION_SET_MEMBER_NICK, { owner: owner,
                                      tid: group_id,
                                      accid: accid,
                                      nick: nickname
                                    }
          )
    end

    def change_owner(owner, group_id, new_owner, leave = 2)
      post( ACTION_CHAHGE_OWNER, { owner: owner, tid: group_id, newowner: new_owner, leave: leave } )
    end

    def set_manager(owner, group_id, members)
      post( ACTION_SET_MANAGER, { owner: owner, tid: group_id, members: members } )
    end

    def unset_manager(owner, group_id, members)
      post( ACTION_UNSET_MANAGER, { owner: owner, tid: group_id, members: members } )
    end

    def set_group_mute(group_id, user_id, ope)
      post( ACTION_SET_GROUP_MUTE, { tid: group_id, accid: user_id, ope: ope } )
    end

    def mute_group_member(owner, group_id, user_id, mute)
      post( ACTION_MUTE_GROUP_MEMBER, { owner: owner, tid: group_id, accid: user_id, mute: mute } )
    end

    def mute_all_group_members(owner, group_id, mute)
      post( ACTION_MUTE_ALL_GROUP_MEMBERS, { owner: owner, tid: group_id, mute: mute } )
    end

    def get_mute_group_members(owner, group_id)
      post( ACTION_GET_MUTE_GROUP_MEMBERS, { owner: owner, tid: group_id } )
    end

    def send_msg(from, to, body = {}, extra = {}, type = 0, options = {})
      post( ACTION_SEND_MSG, { from: from, to: to, body: body.to_json, ope: 0, type: type, ext: extra.to_json }.merge(options) )
    end

    def send_group_msg(from, group_id, body = {}, extra = {}, options = {})
      post( ACTION_SEND_MSG, { from: from, to: group_id, body: body.to_json, ope: 1, ext: extra.to_json }.merge(options) )
    end

    def send_batch_msg(from, to, body = {}, extra = {}, type = 0, options = {})
      post( ACTION_SEND_BATCH_MSG, { from: from, to: to, body: body.to_json, ext: extra.to_json }.merge(options) )
    end

    def send_batch_custom_msg(from, to, body = {}, extra = {}, options = {}, type = 100)
      post( ACTION_SEND_BATCH_MSG, { from: from, to: to, body: body.to_json, type: type, ext: extra.to_json }.merge(options) )
    end

    def send_notification(from, to, extra = {}, options = {})
      post( ACTION_SEND_NOTIFICATION, { from: from,
                                        to: to,
                                        msgtype: 100,
                                        attach: extra.to_json }.merge(options) )
    end

    def send_group_notification(from, to, extra = {}, options = {})
      post( ACTION_SEND_NOTIFICATION, { from: from,
                                        to: to,
                                        msgtype: 1,
                                        attach: extra.to_json }.merge(options) )
    end

    def send_batch_notication(from, to, extra = {}, options)
      post( ACTION_SEND_BATCH_NOTIFICATION, { from: from,
                                              to: to,
                                              msgtype: 1,
                                              attach: extra.to_json }.merge(options) )
    end

    def send_broadcast_msg(from, body, is_offline = false, ttl = 24 * 7, target_OS = ["ios","aos","pc","web","mac"].to_json)
      post( ACTION_SEND_BROADCASE_MSG, { from: from, body: body, isOffline: is_offline, targetOs: target_OS } )
    end

    def add_friend(user_id, friend_id, msg = '')
      post( ACTION_ADD_FRIEND, { accid: user_id, faccid: friend_id, type: 1, msg: msg } )
    end

    def request_add_friend(user_id, friend_id, msg = '')
      post( ACTION_ADD_FRIEND, { accid: user_id, faccid: friend_id, type: 2, msg: msg } )
    end

    def response_friend(user_id, friend_id, state = 3, msg = '')
      post( ACTION_ADD_FRIEND, { accid: user_id, faccid: friend_id, type: state, msg: msg } )
    end

    def set_friend_remark(user_id, friend_id, remark, extra = {})
      post( ACTION_SET_FRIEND_REMARK, { accid: user_id, faccid: friend_id, alias: remark, ex: extra.to_json } )
    end

    def delete_friend(user_id, friend_id)
      post( ACTION_DELETE_FRIEND, { accid: user_id, faccid: friend_id } )
    end

    def get_friends(user_id, update_time = 0)
      post( ACTION_GET_FRIENDS, { accid: user_id, updatetime: update_time } )
    end

    def set_user_mute(user_id, target_user_id, is_muted = 1) 
      post( ACTION_SET_SPECIAL_RELATION, { accid: user_id, targetAcc: target_user_id, relationType: 2, value: is_muted } )
    end

    def add_blacklist(user_id, target_user_id)
      post( ACTION_SET_SPECIAL_RELATION, { accid: user_id, targetAcc: target_user_id, relationType: 1, value: 1 } )
    end

    def remove_blacklist(user_id, target_user_id)
      post( ACTION_SET_SPECIAL_RELATION, { accid: user_id, targetAcc: target_user_id, relationType: 1, value: 0 } )
    end

    def get_blacklist_and_mutelist(user_id)
      post( ACTION_GET_BLACKLIST_AND_MUTELIST, { accid: user_id } )
    end
  end
end
