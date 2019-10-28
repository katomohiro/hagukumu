require 'bundler/setup'
require "google_drive"
require 'slack/incoming/webhooks'
require 'date'

# スプレッドシートの名前
MII_HISTORY_WS_ID = 0
CONFIG_WS_ID = 319868657

# 目標mii
TARGET_MII = 2000

# カラムの位置を特定するための行番号
COLUMN_NAME_ROW = 1


session = GoogleDrive::Session.from_config("client_secret.json")
# 環境変数に置き換える
# MII_SPREADSHEET_ID="1iJj3ujYwuWksiXW4W-Dyr5g0RKToPH72uBXJOeV4W5o"
# ss = session.spreadsheet_by_key(MII_SPREADSHEET_ID)
ss = session.spreadsheet_by_key(ENV['MII_SPREADSHEET_ID'])
mii_history_ws = ss.worksheet_by_gid(MII_HISTORY_WS_ID)
config_ws = ss.worksheet_by_gid(CONFIG_WS_ID)

mii_history = {}

# 列番号の変数作成
(1..config_ws.num_cols).each do |col|
  eval("#{config_ws[COLUMN_NAME_ROW, col]}_COL = col")
end

# チーム名の一覧を取得
(3..config_ws.num_rows).each do |row|

  # LDSクラス名
  team_name = config_ws[row, CONFIG_TEAM_NAME_COL]

  # 名前がからの場合はスキップ
  next if team_name == ""

  # 配列を作成
  mii_history[team_name] = []
end

# mii達成一覧
# ARCHIVEMENT_DATE
# TEAM_NAME
# POINT_ACTION
# MII
# DETAIL

# config
# TEAM_NAME
# POINT_ACTION
# MII

# 列番号の変数作成
(1..mii_history_ws.num_cols).each do |col|
  eval("#{mii_history_ws[COLUMN_NAME_ROW, col]}_COL = col")
end

# ループ開始
(3..mii_history_ws.num_rows).each do |row|

  # 達成日
  archievement_date = mii_history_ws[row, ACHIEVEMENT_DATE_COL]
  # チーム名
  team_name = mii_history_ws[row, TEAM_NAME_COL]
  # 達成項目
  point_action = mii_history_ws[row, POINT_ACTION_COL]
  # mii
  mii = mii_history_ws[row, MII_COL]
  # 詳細
  detail = mii_history_ws[row, DETAIL_COL]

  # 達成日がからの場合はスキップ
  next if archievement_date == ""

  history_data = {
    archievement_date: archievement_date,
    point_action: point_action,
    mii: mii,
    detail: detail,
  }

  mii_history[team_name].push(history_data)
end

# 文章作成開始
date = Date.today
msg = "<!channel> \n"
msg += "#{date.year}.#{date.month}.#{date.day} mii達成状況速報\n"
msg += "```"
msg += "＼#{Date.today.month + 1}月目標#{TARGET_MII}mii！／\n"
msg += "\n"

def get_team_mii_history_text(mii_history, team_name)
  msg = "▼ #{team_name} 達成状況 ▼\n"
  msg += "\n"

  total_mii = 0

  mii_history[team_name].each do |h|
    # 達成日
    # archievement_date = h[:archievement_date]
    # 達成項目
    point_action = h[:point_action]
    # mii
    mii = h[:mii].gsub(",","")
    # 詳細
    detail = h[:detail]

    total_mii += mii.to_i
    msg += "#{(point_action + "（" + detail + "）").ljust(25, "　")}：#{mii}mii\n"
  end

  msg += "\n"
  msg += "合計【#{total_mii}mii】\n"
  msg += "---------\n"
  msg += "\n"
end
mii_history.each do |team, history|
  msg += get_team_mii_history_text(mii_history, team)
end
msg += "```"

puts msg

slack = Slack::Incoming::Webhooks.new(ENV['MII_WEBHOOK_URL'])
slack.post(msg)
