require 'bundler/setup'
require "google_drive"
require 'slack/incoming/webhooks'
require 'date'

# スプレッドシートの名前
SYUUKYAKUKANRI_WS_TITLE = "顧客管理"

# クラス名
LDS_CLASS_TOKYO_1 = "東京18期"
LDS_CLASS_TOKYO_2 = "東京19期"
LDS_CLASS_ONLINE_1 = "オンライン4期"
LDS_CLASS_ONLINE_2 = "オンライン5期"

# 全国目標人数
TARGET_NUMBER = 110

# カラムの位置を特定するための行番号
COLUMN_NAME_ROW = 2






session = GoogleDrive::Session.from_config("client_secret.json")
ws = session.spreadsheet_by_key(ENV['SYUKYAKUKANRI_SPREADSHEET_ID']).worksheet_by_title(SYUUKYAKUKANRI_WS_TITLE)

syukyaku_data = {
  "#{LDS_CLASS_TOKYO_1}" => {confirmed: [], cooling_off_term: []},
  "#{LDS_CLASS_TOKYO_2}" => {confirmed: [], cooling_off_term: []},
  "#{LDS_CLASS_ONLINE_1}" => {confirmed: [], cooling_off_term: []},
  "#{LDS_CLASS_ONLINE_2}" => {confirmed: [], cooling_off_term: []},
}

# DATE
# NAME
# UNIVERSITY
# GRADE
# SYUKYAKU_CHANNEL
# INTRODUCER
# SYUKYAKU_MEMBER
# EVENT
# MUSHA
# LDS_CLASS
# TAIKENKAI_ATTENDANCE
# TAIKENKAI_TYPE
# TAIKENKAI_DATE
# TAIKENKAI_FACILITATOR
# APPLICATION
# COOLING_OFF
# PERSONA
# FOLLOW_MEMBER
# FOLLOW_STATUS
# NOT_APPLY_REASON

# 列番号の変数作成
(1..ws.num_cols).each do |col|
  puts ws[COLUMN_NAME_ROW, col]
  eval("#{ws[COLUMN_NAME_ROW, col]}_COL = col")
end

# ループ開始
(3..ws.num_rows).each do |row|

  # LDSクラス名
  lds_class = ws[row, LDS_CLASS_COL]
  # 名前
  name = ws[row, NAME_COL]
  # 流入経路
  syukyaku_channel = ws[row, SYUKYAKU_CHANNEL_COL].empty? ? "?" : ws[row, SYUKYAKU_CHANNEL_COL]
  # 集客担当
  syukyaku_member = ws[row, SYUKYAKU_MEMBER_COL].empty? ? "?" : ws[row, SYUKYAKU_MEMBER_COL]
  # 本講座申込
  application = ws[row, APPLICATION_COL]
  # 本講座参加
  cooling_off = ws[row, COOLING_OFF_COL]
  # フォロー担当
  follow_member = ws[row, FOLLOW_MEMBER_COL].empty? ? "?" : ws[row, FOLLOW_MEMBER_COL]

  # 名前がからの場合はスキップ
  next if name == ""

  applicant_data = {
    name:name,
    syukyaku_channel: syukyaku_channel,
    syukyaku_member: syukyaku_member,
    follow_member: follow_member,
  }

  # エラー防止
  next if syukyaku_data[lds_class].nil?

  if application == "申込"
    case cooling_off
    when "確定"
      syukyaku_data[lds_class][:confirmed].push(applicant_data)
    when "キャンセル"
    else
      syukyaku_data[lds_class][:cooling_off_term].push(applicant_data)
    end
  end

end

# 確定済み人数集計
tokyo_1_num = syukyaku_data["#{LDS_CLASS_TOKYO_1}"][:confirmed].count
tokyo_2_num = syukyaku_data["#{LDS_CLASS_TOKYO_2}"][:confirmed].count
online_1_num = syukyaku_data["#{LDS_CLASS_ONLINE_1}"][:confirmed].count
online_2_num = syukyaku_data["#{LDS_CLASS_ONLINE_2}"][:confirmed].count
zenkoku = tokyo_1_num + tokyo_2_num + online_1_num + online_2_num

# 文章作成開始
date = Date.today
msg = "<!channel> \n"
msg += "#{date.year}.#{date.month}.#{date.day} 集客速報\n"
msg += "```"
msg += "＼必達全国#{TARGET_NUMBER}人！／\n"
msg += "【現状（確定）】全国：#{zenkoku}人\n"
msg += "・#{LDS_CLASS_TOKYO_1}：#{tokyo_1_num}人\n"
msg += "・#{LDS_CLASS_TOKYO_2}：#{tokyo_2_num}人\n"
msg += "・#{LDS_CLASS_ONLINE_1}：#{online_1_num}人\n"
msg += "・#{LDS_CLASS_ONLINE_2}：#{online_2_num}人\n"
msg += "\n"

def syukyaku_jokyo(syukyaku_data, msg, lds_class_name)
  msg += "＜#{lds_class_name}＞\n"
  syukyaku_data[lds_class_name][:confirmed].each_with_index do |applicant, idx|
    idx += 1
    if idx != 1 && idx % 5 == 0
      if idx.even?
        msg += "０"
      else
        msg += "５"
      end
    else
      msg += "・"
    end
    msg += "#{applicant[:name].ljust(5, "　")}：#{applicant[:syukyaku_channel]} #{applicant[:syukyaku_member]}\n"
  end

  # 未確定が存在する場合
  if syukyaku_data[lds_class_name][:cooling_off_term].count > 0
    msg += "\n"
    msg += "「未確定」\n"
  end

  syukyaku_data[lds_class_name][:cooling_off_term].each do |applicant|
    msg += "・#{applicant[:name].ljust(5, "　")}：#{applicant[:syukyaku_channel]} #{applicant[:follow_member]}フォロー\n"
  end
  msg += "\n"
end

msg = syukyaku_jokyo(syukyaku_data, msg, LDS_CLASS_TOKYO_1)
msg = syukyaku_jokyo(syukyaku_data, msg, LDS_CLASS_TOKYO_2)
msg = syukyaku_jokyo(syukyaku_data, msg, LDS_CLASS_ONLINE_1)
msg = syukyaku_jokyo(syukyaku_data, msg, LDS_CLASS_ONLINE_2)
msg += "```"

puts msg

slack = Slack::Incoming::Webhooks.new(ENV['SYUKYAKU_WEBHOOK_URL'])
slack.post(msg)
