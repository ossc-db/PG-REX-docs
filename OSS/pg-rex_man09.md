[^2]: PostgreSQL関連のツールの対応状況によって日本語が表示されないこともあります。

[^3]: 参照先：[<https://www.postgresql.jp/document/14/html/functions-admin.html>](https://www.postgresql.jp/document/14/html/functions-admin.html)

[^4]: 参照先：[<https://www.postgresql.jp/document/14/html/functions-admin.html>](https://www.postgresql.jp/document/14/html/functions-admin.html)

[^5]: 参照先：[<https://www.postgresql.jp/document/14/html/warm-standby.html#STANDBY-PLANNING>](https://www.postgresql.jp/document/14/html/warm-standby.html#STANDBY-PLANNING)

[^7]: 参照先：[<https://www.postgresql.jp/document/14/html/hot-standby.html#HOT-STANDBY-CONFLICT>](https://www.postgresql.jp/document/14/html/hot-standby.html#HOT-STANDBY-CONFLICT)

[^15]: リストアコマンドはpm\_pcsgen環境定義書に設定します。設定方法は『[@sec:PostgreSQLの設定](#sec:PostgreSQLの設定) [PostgreSQLの設定](#sec:PostgreSQLの設定)』を参照してください。

[^16]: tcp\_keepalives\_idle、tcp\_keepalives\_interval、tcp\_keepalives\_countの設定を指します。

[^17]: アーカイブコマンドの設定は『[@sec:postgresql.confの編集](#sec:postgresql.confの編集) [postgresql.confの編集](#sec:postgresql.confの編集)』を参照してください。

[^20]: 参照先: [<https://www.postgresql.jp/document/14/html/hot-standby.html#HOT-STANDBY-ADMIN>](https://www.postgresql.jp/document/14/html/hot-standby.html#HOT-STANDBY-ADMIN)

[^21]: 参照先：[<https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-BASE-BACKUP>](https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-BASE-BACKUP)

[^22]: バックアップ履歴ファイルは、拡張子が.backupのファイルを指します。  
[<https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-BASE-BACKUP>](https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-BASE-BACKUP)

[^23]: タイムライン履歴ファイルは、拡張子が.historyのファイルを指します。  
[<https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-TIMELINES>](https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-TIMELINES)

[^32]: バックアップ履歴ファイルは、拡張子が.backupのファイルを指します。  
[<https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-BASE-BACKUP>](https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-BASE-BACKUP)

[^33]: タイムライン履歴ファイルは、拡張子が.historyのファイルを指します。  
[<https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-TIMELINES>](https://www.postgresql.jp/document/14/html/continuous-archiving.html#BACKUP-TIMELINES)

[^37]: PostgreSQLのサーバログファイルの場所は設定により異なります。詳細は『PostgreSQLドキュメント』を参照してください。

[^38]: レプリケーション受付用の仮想IPアドレスの設定

[^39]: 相手のノードのD-LANのIPアドレスの設定

[^40]: ダウンロードサイト：[<https://linux-ha.osdn.jp/wp/dl>](https://linux-ha.osdn.jp/wp/dl)

[^41]: インストールDVDがメディア挿入時に自動マウントされた場合は、一旦手動でアンマウントし、再度マウントしてください。

[^43]: [https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/assembly_configuring-fencing-configuring-and-managing-high-availability-clusters#proc_configuring-acpi-for-fence-devices-configuring-fencing](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/assembly_configuring-fencing-configuring-and-managing-high-availability-clusters#proc_configuring-acpi-for-fence-devices-configuring-fencing)

[^44]: logind.confを修正する手順は、デフォルトターゲットがmultiuser.targetの場合にのみ有効です。graphical.target等の他のデフォルトターゲットの場合は、Red Hat社の次のドキュメントを参照し てください。
[https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/s2-acpi-disable-logind-ca](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/s2-acpi-disable-logind-ca)

[^46]: リソース定義xmlファイル生成時にリソース定義用スクリプトファイル(pm_pcsgen_env.sh)も生成されますが、本マニュアルでは利用しません。

[^47]: pcs statusでノード名との対応が表示されます。詳細は【ノード情報表示部】を参照してください。

[^49]: 以降はRHELと表記します。

[^50]: 以降はRHEL HA Add-Onと表記します。

[^53]: 本マニュアルの『[@sec:PostgreSQLのバックアップ](#sec:PostgreSQLのバックアップ) [PostgreSQLのバックアップ](#sec:PostgreSQLのバックアップ)』にある操作例を参照

[^54]: RHEL HA Add-On 8.8に同梱されたものです。

[^56]: 『[@sec:対象とするソフトウェアとバージョン](#sec:対象とするソフトウェアとバージョン) [対象とするソフトウェアとバージョン](#sec:対象とするソフトウェアとバージョン)』を確認して、対象バージョンのドキュメントを参照してください。
