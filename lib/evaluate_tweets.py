#!/usr/bin/env python
# -*- coding: utf-8 -*-

import cgi
import csv
import json
import urllib
import random
import twitter
import mecab_library
import mecab_tokenizer
from datetime import datetime
from datetime import timedelta
from pp import pp


def twitter_search(q, access_token, access_token_secret, since_id=0):
	# @tomohitoy
	consumer_token = "xLq3UCn9rW6ZW7dTfBdnw"
	consumer_secret = "XeTnRZm2F7H3HiE9r3sBnYdOABUAggwxhZEb0q8CM"		
	auth = twitter.oauth.OAuth(access_token, access_token_secret, consumer_token, consumer_secret)
	twitter_api = twitter.Twitter(auth=auth)
	
	search_results = twitter_api.search.tweets(q=q, count=count, locale="ja", include_entities=False, since_id=since_id, result_type="recent")
	statuses = search_results["statuses"]
	
	for _ in range(5):
	#print "Length of statuses", len(statuses)
		try:
			next_results = search_results['search_metadata']['next_results']
		except: # No more results when next_results doesn't exist
			#print "End of searching " + q
			break
			
		# Create a dictionary from next_results, which has the following form:
		# ?max_id=313519052523986943&q=NCAA&include_entities=1
		kwargs = dict([ kv.split('=') for kv in next_results[1:].split("&") ])
		
		search_results = twitter_api.search.tweets(**kwargs)
		statuses += search_results['statuses']

	return statuses

# トークンの最頻語を最低頻度を指定して出力
def tokens_freqdist(tokens, thres=3):
	tokens_dict = {}
	for token in tokens:
		if tokens_dict.has_key(token):
			tokens_dict[token] += 1
		else:
			tokens_dict[token] = 1
	tokens_list = sorted(tokens_dict.items(), key=lambda x:x[1], reverse=True)
	tokens_list = [token_list for token_list in tokens_list if token_list[1] >= thres]
	return tokens_list

# 日本語評価極性辞書（用言編）ver.1.0（2008年12月版）
# 小林のぞみ，乾健太郎，松本裕治，立石健二，福島俊一. 意見抽出のための評価表現の収集. 自然言語処理，Vol.12, No.2, pp.203-222, 2005.
# ポジ（経験）、ポジ（評価）、ネガ（経験）、ネガ（評価）の4種類の評価値
wago_pn = csv.reader(open("wago.121808.pn.txt", "rb"))
wago_pn = csv.reader(open("wago.121808.pn.txt", "rb"), delimiter="\t")
wago_pn = [w for w in wago_pn if w[1] not in ["", "いい"]]

###########################
# 評価値別属性抽出パターン
###########################

# Twitter検索
query = cgi.FieldStorage()['q'].value
access_token = cgi.FieldStorage()['token'].value
access_token_secret = cgi.FieldStorage()['secret'].value
#query = "自民党"
results = twitter_search(query , access_token, access_token_secret)

query.replace("　", " ")
query = mecab_tokenizer.tokenize(query.decode("utf-8"), pos_list=["名詞"], stop_words=["http", "co", "RT"], omit_others=True)

# ツイートに評価値が含まれる場合、evaluated_textsに評価値、str、トークンを追加
evaluated_sents = []
for res in results:
	text = res["text"].replace("\\", "")
	created_at = str(datetime.strptime(res["created_at"], '%a %b %d %H:%M:%S +0000 %Y') + timedelta(hours=9))
	for evaluate in wago_pn:
		if evaluate[1] != "" and text.find(evaluate[1].replace(" ", "").decode("utf-8")) > -1:
			evaluated_sents.append({
					"evaluate_word": [
						evaluate[0], 
						evaluate[1]
					], 
					"text": [text.encode("utf-8"), res["user"]["screen_name"], res["user"]["profile_image_url"], created_at], 
					"tokens": mecab_tokenizer.tokenize(text, pos_list=["名詞"], stop_words=["http", "co", "RT"], omit_others=True)
					})


# 属性ごとのポジネガ数カウント
attrs_noun = []
for sent in evaluated_sents:
	if "ポジ" in sent["evaluate_word"][0]:
		evaluate = "posi"
	elif "ネガ" in sent["evaluate_word"][0]:
		evaluate = "nega"
	attrs_noun += [[noun.encode("utf-8"), evaluate, sent["text"], sent["evaluate_word"][1]] for noun in sent["tokens"] if noun not in query]
	#attrs_noun += [(noun.encode("utf-8"), evaluate, sent["text"], sent["evaluate_word"][1]) for noun in sent["tokens"]]

# 重複を取り除く
_attrs_noun = []
for attr in attrs_noun:
	if attr not in _attrs_noun:
		_attrs_noun.append(attr)

attrs_noun = _attrs_noun

attrs_count = {}
for attr in attrs_noun:
	attrs_count[attr[0]] = {}
	attrs_count[attr[0]]["posi"] = 0
	attrs_count[attr[0]]["nega"] = 0
	attrs_count[attr[0]]["total"] = 0
for attr in attrs_noun:
	if attr[1] == "posi":
		attrs_count[attr[0]]["posi"] += 1
		attrs_count[attr[0]]["total"] += 1
	elif attr[1] == "nega":
		attrs_count[attr[0]]["nega"] += 1
		attrs_count[attr[0]]["total"] += 1

attrs_count_json = []
for attr in attrs_count.items():
	attr_dict = attr[1]
	if attr_dict["posi"] > attr_dict["nega"]:
		attr_dict["class"] = "posi"
	elif attr_dict["posi"] < attr_dict["nega"]:
		attr_dict["class"] = "nega"
	else:
		attr_dict["class"] = "equal"
	# 表示が重ならないように工夫
	# attr_dict["posi"] += random.random()
	# 出現頻度でスクリーニング
	if attr_dict["total"] >= 1:
		attr_dict["name"] = attr[0]
		attrs_count_json.append(attr_dict)
#json.dump(attrs_count_json, open("attrs_count.json", "w"))

#"text": [text.encode("utf-8"), res["user"]["screen_name"], res["user"]["profile_image_url"], created_at]
attrs_noun_json = []
for attr_noun in attrs_noun:
	text = attr_noun[2][0].replace("\n"," ")
	#text = text.replace("\\", "")
	text = text.replace(attr_noun[0], "<span class='%s'>%s</span>" % (attr_noun[1], attr_noun[0]))
	text = "<img src='%s' class='user-img'/><a href='http://twitter.com/%s' class='user'>%s</a><span class='created_at'>%s</span><br/>%s" % (attr_noun[2][2].encode("utf-8"), attr_noun[2][1].encode("utf-8"), attr_noun[2][1].encode("utf-8"), attr_noun[2][3], text)
	attr_noun_json = {"attr": attr_noun[0], "pn": attr_noun[1], "text": text, "evaluate_word": attr_noun[3]}
	attrs_noun_json.append(attr_noun_json)
#json.dump(attrs_noun_json, open("attrs_noun.json", "w"))

attrs_json = {"count": attrs_count_json, "noun": attrs_noun_json}

print "Content-Type: application/json; charset=utf-8\n"
#pp(attrs_json)
print json.dumps(attrs_json)