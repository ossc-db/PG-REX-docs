アーカイブログの削除 {#sec:アーカイブログの削除_cmd}
--------------------

本節では、コマンドを直接実行してデータベースの復旧に必要のないファイルをアーカイブディレクトリから削除する手順について記述します。

本節の作業はpostgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

### PostgreSQLアーカイブログの削除

運用を続けていくにしたがってアーカイブファイルの容量は増えていくため、継続的な運用のためには適宜削除を行う必要があります。

PostgreSQLのアーカイブログ、バックアップ履歴ファイル[^32]、タイムライン履歴ファイル[^33]は、以下の条件を全て満足する場合、アーカイブディレクトリから削除することができます。

-   管理している最古のバックアップ取得時点以前のファイル
-   Standbyが既に反映・チェックポイント済みのファイル

::: {custom-style="First Paragraph"}
　
:::

定期的に以下の手順に従って不要なファイルを削除します。

::: {custom-style="First Paragraph"}
　
:::

(1) 最古のバックアップに必要な最も古いWALファイル名を取得

    最古のバックアップが存在するサーバで、最古のバックアップのbackup\_labelファイルに記述されたSTART WAL LOCATIONの括弧内のWALファイル名を取得します。

    ここでは管理する最古のバックアップの格納先を、\$OLDEST\_BACKUPとします。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [\[\~\] \$ cat \$OLDEST_BACKUP/pgdata/backup_label]{custom-style="Verbatim Char"}\
  [START WAL LOCATION:]{custom-style="red-bold"}[\ 6A/4E0013D8 (file\ ]{custom-style="Verbatim Char"}[000000730000006A0000004E]{custom-style="red-bold"}[)]{custom-style="Verbatim Char"}\
  [CHECKPOINT LOCATION: 6A/4E002740]{custom-style="Verbatim Char"}\
  [BACKUP METHOD: streamed]{custom-style="Verbatim Char"}\
  [BACKUP FROM: primary]{custom-style="Verbatim Char"}\
  [START TIME:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [LABEL: pg_basebackup base backup]{custom-style="Verbatim Char"}\
  [START TIMELINE: 73]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(2) Standbyに必要な最も古いWALファイル名を取得

    pgrex02で、pg\_controldataを実行して、Standbyの\"最終チェックポイントのREDO WALファイル\"の値を取得します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [\[pgrex02\] \$ pg_controldata \$PGDATA]{custom-style="Verbatim Char"}\
  [：(略)]{custom-style="Verbatim Char"}\
  [最終チェックポイントのREDO WALファイル:\ \ \ \ 000000750000006A00000051]{custom-style="red-bold"}\
  [：(略)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) 削除対象の計算

    (1)のWALファイル名と(2)のWALファイル名を辞書順で比較します。その結果、小さいほうのWALファイル名を以降の手順で使用します。

::: {custom-style="page-break"}
　
:::

(4) データベースの復旧に必要のないファイルの削除

    両ノードで、(3)で決定したWALファイル名よりも古いアーカイブファイルを削除します。

    以下のコマンドはpgrex01を想定した例になります。以下の手順をpgrex01で実行後、必ずpgrex02でも同じ手順を実行してください。

    ls -lコマンドを用いてアーカイブディレクトリを辞書順にソートして出力します。このとき、(3)で決定したWALファイル名と同じ名前のファイルをチェックします。そのファイルより前に出力されたファイルを削除することができます。ただし、そのWALファイル名と先頭8桁が同じタイムライン履歴ファイル(\*\*\*\*\*\*\*\*.history)は削除しません。

    ::: {custom-style="First Paragraph"}
    　
    :::

    (例)

    (3)で「000000730000006A0000004E」と決定した場合、赤字が削除可能なファイルとなります。これらのファイルをrmコマンド等で削除してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [\[pgrex01\] \$ ls \-l /dbfp/pgarch/arc1]{custom-style="Verbatim Char"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000710000006A0000004B]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000710000006A0000004B.00000020.backup]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[00000072.history]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000720000006A0000004C]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000720000006A0000004D]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000720000006A0000004E]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000720000006A0000004F]{custom-style="red-bold"}\
  [\~ 00000073.history]{custom-style="Verbatim Char"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000730000006A0000004C]{custom-style="red-bold"}\
  [\~\ ]{custom-style="Verbatim Char"}[000000730000006A0000004D]{custom-style="red-bold"}\
  [\~ 000000730000006A0000004E]{custom-style="Verbatim Char"}\
  [\~ 000000730000006A0000004E.000013D8.backup]{custom-style="Verbatim Char"}\
  [\~ 000000730000006A0000004F]{custom-style="Verbatim Char"}\
  [\~ 000000730000006A00000050]{custom-style="Verbatim Char"}\
  [\~ 00000074.history]{custom-style="Verbatim Char"}\
  [\~ 000000740000006A00000050]{custom-style="Verbatim Char"}\
  [\~ 000000740000006A00000051]{custom-style="Verbatim Char"}\
  [\~ 00000075.history]{custom-style="Verbatim Char"}\
  [\~ 000000750000006A00000051]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

