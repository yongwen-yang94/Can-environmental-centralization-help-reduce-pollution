# -*- coding:utf-8 -*-

import jieba.analyse  # 引入词库
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator  # 词云
import jieba
from collections import Counter  # 统计
import matplotlib.pyplot as plt  # 数据可视化工具
from wordcloud import WordCloud

# 1.读取数据
with open("test.txt", "rb") as f:
    text = f.read()

# 2.基于 TextRank 算法的关键词抽取,top100
keywords = jieba.analyse.textrank(text, topK=100, withWeight=False, allowPOS=('ns', 'n', 'vn', 'v'))
file = ",".join(keywords)  # 逗号分隔
list = jieba.cut(text)
c = Counter()
#
# 给分词定义条件进行筛选统计词频
for x in list:
    if len(x) > 1 and x != '\r\n':
        c[x] += 1

with open(r'bb.txt', 'w', encoding='gbk') as fw:
    for (k, v) in c.most_common():
        fw.write(k + ' ' + str(v) + '\n')
    fw.close()

