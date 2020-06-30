# Created by maofei at 2019/5/20
Feature: Functional testing of global sequence generated by distributed timestamp

  @skip_restart @skip #because of issue:http://10.186.18.11/jira/browse/DBLE0REQ-327
  Scenario: Verify the illegal value of the parameter in the sequence_distributed_conf.properties  #1
  #    case points:
  #  1.Verify the illegal value of the INSTANCEID
  #  2.Verify the illegal value of the START_TIME
  #  3.START_TIME>the time of dble start
  #  4.START_TIME+17 years<the time of dble start
    Given reset dble registered nodes in zk
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_auto" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" function="hash-four" shardingColumn="id"/>
    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a sequenceHandlerType=3
    $a sequenceStartTime=2010-11-04 09:42:54
    $a sequenceInstanceByZk=false
    """
    Then start dble in order

    #case 1: Verify the illegal value of the INSTANCEID
     Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DinstanceId/c -DinstanceId=522
    """
    Then restart dble in "dble-1" failed for
    """
     instanceId can't be greater than 511 or less than 0
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DinstanceId/c -DinstanceId=-1
    """
    Then restart dble in "dble-1" failed for
    """
     INSTANCEID Id can't be greater than 511 or less than 0
    """
   Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DinstanceId/c -DinstanceId=01
    """
    Given Restart dble in "dble-1" success

    #case 2: Verify the illegal value of the START_TIME
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceStartTime/c sequenceStartTime=2010/11/04 09:42:54
    """

    Then stop dble in "dble-1"
    #wait zk remove information about dble-1
    Given sleep "60" seconds
    Then start dble in "dble-1" failed for
    """
     "2010/11/04 09:42:54" is malformed at "/11/04 09:42:54"
    """
#    Given Restart dble in "dble-1" success
#    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
#    """
#    sequenceStartTime in cluster.cnf parse exception, starting from 2010-11-04 09:42:54
#    """
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceStartTime/c sequenceStartTime=2010-11-04 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    #case 3: START_TIME>the time of dble start
     Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceStartTime/c sequenceStartTime=2190-10-01 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    sequenceStartTime in cluster.cnf mustn'\''t be over than dble start time, starting from 2010-11-04 09:42:54
    """

    #case 4: START_TIME+17 years<the time of dble start
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceStartTime/c sequenceStartTime=2000-10-01 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                | expect       | db      |
      | conn_0 | False    |drop table if exists test_auto                      | success      | schema1 |
      | conn_0 | False    |create table test_auto(id bigint,time char(120))    | success      | schema1 |
      | conn_0 | True     |insert into test_auto values(1)                     | Global sequence has reach to max limit and can generate duplicate sequences  | schema1 |
    Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    /sequenceStartTime/c sequenceStartTime=2010-11-04 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | sql                              | expect         | db     |
      |insert into test_auto values(1)   | success        | schema1 |