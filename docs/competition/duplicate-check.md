# MoonIon 查重记录

- 检查日期：2026-09-17
- 复核日期：2026-09-17
- 官方助手：已按 osc2026-guide 本地流程执行 moon search <keyword> --limit N，并阅读返回模块名称、简介与关键词；未把“精确项目名缺失”当成不存在的充分条件。
- 检索工具：moonsqlguard-evidence/moon-latest/bin/moon.exe（moon 0.1.20260915 / moonc 0.10.13+cbb11c36f）
- 原始输出：_live-search-20260917-replace 与 extra 子目录

## 候选项目

MoonIon：把 amazon-ion/ion-python（Apache-2.0）与 Amazon Ion 1.0 规范中的值模型、文本编码、二进制编码和本地符号表移植为 MoonBit 纯库。范围是 IonValue、annotation、decimal/timestamp、text loads/dumps、binary loads/dumps、本地 $ion_symbol_table；不做 Ion 1.1、Ion Schema、Ion Hash、共享符号表网络目录、AWS SDK。

## 三方向比较

| 候选 | 领域 | MoonCakes 关键词 | 登记簿相邻 | 结论 |
| --- | --- | --- | --- | --- |
| MoonIon / ion-python | 通用自描述数据交换 | ion、amazon-ion、ion-python、ion-java、ionjs、iontext 为空；ionbinary/simpleion 为 VCode/文本渲染误报 | 无 Ion 指纹。CBOR/MessagePack/BSON/protobuf 是其他编码 | 选定，通用性明显高于 xAPI |
| MoonWebDAV / RFC 4918 | 远程文件系统属性与锁 | webdav 仅命中 justinwongcn/moon-ical 的 CalDAV PROPFIND 子集；carddav 为空 | CalDAV/iCalendar 已有日历服务，严格相邻 | 备选但放弃 |
| MoonLuceneQuery / Lucene QueryParser | 全文检索查询语法 | lucene 仅命中 morning-start/prism 的 Lucent LLM 中间表示，不是 Lucene | 查询语言族有 SQL/JSONPath/CEL/XPath | 第三领域对照，未选 |

## 关键词与结果

空结果（无模块）：ion、amazon-ion、ion-python、ion-java、ionjs、iontext、iso4217、grib、hdf5、rtf、nfs、gpx、kml、gtfs、wkb、ubjson、sbe、amqp、zeromq、memcached、tftp。

有模块但能力不重合：

- ionbinary → Milky2018/vcode 本地代码下降，不是 Ion binary。
- simpleion → mizchi/text 字形缓存，不是 ion.simpleion。
- cbor / msgpack / bson / protobuf / jsonrpc / yaml / toml → 其他数据编码，核心循环不是 Ion 符号表 + 文本/二进制双编码。
- jsonschema / cloudevents / html_parser / csv_parser / tzif-engine → 已被占用的通用库，不复用。
- moon-ical → CalDAV/iCalendar，不是 Amazon Ion。
- profinet_master/snmp → 工业 SNMP 子集，不是 Ion。

GitHub 检索 moonbit ion 无 Amazon Ion 编解码仓库。ion-python 许可证仍为 Apache-2.0。

## 重合度判断

未发现 MoonBit 生态中已存在、功能高度重合且维护良好的 Amazon Ion 库。CBOR/MessagePack/BSON 处理的是各自的 type nibble 或 length-prefix 文档，不包含 $ion_1_0 版本标记、$ion_symbol_table、annotation wrapper、sexp 与 Ion timestamp/decimal。protobuf 是 IDL schema codec，不是自描述 Ion。

## 差异化说明

本项目的核心循环是 Ion 1.0 文本/二进制往返与本地符号表，不是通用 JSON，也不是 RFC 8949 CBOR。因此即使都出现 list/map/int，项目身份仍是 Amazon Ion 编解码库。xAPI 作为已完成项目保留，本项目不覆盖学习记录语句。

## 最终决策

锁定 MoonIon。WebDAV 因 CalDAV 相邻放弃。Lucene QueryParser 作为不同领域对照保留在记录中但不实现。MoonXAPI 维持 completed，不复用仓库。

## 先前项目

本参赛者已完成并登记的 MoonChange、MoonXAPI 分别属于路径匹配优化和学习记录语句，与 Amazon Ion 无三维重合。
