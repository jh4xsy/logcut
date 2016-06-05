#!/usr/bin/ruby
#
# $Id: logcut.rb 46 2012-03-31 02:20:40Z jh4xsy $
#
# GPSMANの出力したGPXファイルを日単位で切り出す
#
require "scanf"

#
# trackのZ時をJSTに変換, 日付を返す
#
def get_datime(str)

  gmt_offset_hour = 9

  yy, mm, dd, h, m, s = str.scanf("  <time>%4d-%02d-%02dT%02d:%02d:%02dZ</time>")

  otime = Time.gm(yy, mm, dd, h, m, s)

  ptime = otime + 3600 * gmt_offset_hour
  
  return ptime.strftime("%Y%m%d")

end

#
# GPXファイルをgpsman風に書き出す
#
def phead(f)

  f.printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  f.printf("<gpx\n")
  f.printf(" version=\"1.0\"\n")
  f.printf(" creator=\"GPSBabel - http://www.gpsbabel.org\"\n")
  f.printf(" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n")
  f.printf(" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd\">\n")
  f.printf(" <author>JH4XSY</author>\n")
  f.printf(" <email>jh4xsy@jarl.com</email>\n")
  f.printf(" <url>JH4XSY</url>\n")
  f.printf(" <urlname>http://jh4xsy.ddo.jp/</urlname>\n")

  ctime = Time.now
  gtime = ctime.getutc
  ptime = gtime.strftime("%Y-%m-%dT%H:%M:00Z")
  f.printf("<time>%s</time>\n", ptime)

  f.printf("<trk>\n")
  f.printf("<name>ACTIVE LOG</name>\n")
  f.printf("<trkseg>\n")

end

#
# GPXファイルを閉じる
#
def ptail(f)

  f.printf("</trkseg></trk>\n")
  f.printf("</gpx>\n")

end

#
# --- メイン -------------------------------------------------------
#

# --- 引数チェック ---

if ARGV[0] == nil
  print "logcut file.gpx", "\n"
  exit
else
  filename = ARGV[0]
  if File.exist?(filename) 

  else
    printf("%s not found\n",filename)
    exit
  end
end

# --- GPXファイルの処理 ---

f = open(filename, "r")

while f.gets
  
  if $_ =~ /trkseg/		# ヘッダを読み飛ばす
    break
  end
  
end

cnt = 0				# trk のカウンタ

prev_datime = "19631015"
oname = sprintf("%s.gpx", prev_datime)
of = open(oname, "w")		# dummy file open

while 1

  s1 = f.gets			# <trkpt>要素

    if s1 =~ /\/trkseg/		  # トラックセグメントの終了を待つ
      s1 = f.gets
      s1 = f.gets

      if s1 =~ /\/gpx/            # トラックの終了を待つ
        break
      end

      s1 = f.gets		  # 不要なタグ，読み飛ばし
      s1 = f.gets
      s1 = f.gets
      s1 = f.gets
    end

  s2 = f.gets			# <ele>要素

  s3 = f.gets			# <time>要素

  s4 = f.gets			# <speed>要素

  s5 = f.gets			# <name>要素

  datime = get_datime(s3) 
  if datime != prev_datime	# 日付の変更をチェック

    ptail(of)			# 2行追加
    of.close			# ファイルクローズ

    print datime, "\n"
    prev_datime = datime

    oname = sprintf("%s.gpx", datime)
    of = open(oname, "w")	# 新しいGPXファイルを作成 
    phead(of)			# ヘッダ作成

  end

  s6 = f.gets
 
  of.print s1			# trackを別ファイルに出力
  of.print s2
  of.print s3
  of.print s4
  of.print s6 
 
  cnt += 1 

end

f.close

ptail(of)			# 忘れずに2行追加

print "Total: ", cnt, " points.\n"
