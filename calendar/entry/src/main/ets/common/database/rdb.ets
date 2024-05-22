


//RDB数据库类
import relationalStore from '@ohos.data.relationalStore';
//import CommonConstants from '../constants/CommonConstants';
import Logger from '../utils/Logger';

export default class Rdb {
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private columns: Array<string>;

  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
  }
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  getRdbStore(callback: Function = () => {
  }) {
    // 如果已经获取到RdbStore则不做操作
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info('[Debug.Rdb]', 'getRdbStore() has no callback!');
      return;
    }
    if (this.rdbStore !== null) {
      Logger.info('[Debug.Rdb]', 'The rdbStore exists.');
      callback();
      return
    }
    // 应用上下文，使用API9 Stage模型的Context
    let context: Context = getContext(this) as Context;
    relationalStore.getRdbStore(context, Rdb.STORE_CONFIG, (err, rdb) => {
      if (err) {
        Logger.error('[Debug.Rdb]', `gerRdbStore() failed, err: ${err}`);
        return;
      }
      this.rdbStore = rdb;
      // 获取到RdbStore后，需使用executeSql接口初始化数据库表结构和相关数据
      this.rdbStore.executeSql(this.sqlCreateTable);
      Logger.info('[Debug.Rdb]', 'getRdbStore() finished.');
      callback();
    });
  }
  //插入数据
  insertData(data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info('[Debug.Rdb]', 'insertData() has no callback!');
      return;
    }
    // 用于记录插入是成功的flag
    let resFlag: boolean = false;
    // 存储键值对的类型，表示要插入到表中的数据行
    const valueBucket: relationalStore.ValuesBucket = data;
    if (this.rdbStore) {
      this.rdbStore.insert(this.tableName, valueBucket, (err, ret) => {
        if (err) {
          Logger.error('[Debug.Rdb]', `insertData() failed, err: ${err.code}`);
          callback(resFlag);
          return;
        }
        Logger.info('[Debug.Rdb]', `insertData() finished: ${ret}`);
        callback(ret);
      });
    }
  }
  //删除数据
  deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info('[Debug.Rdb]', 'deleteData() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    if (this.rdbStore) {
      //predicates表示要删除数据的操作条件
      this.rdbStore.delete(predicates, (err, ret) => {
        if (err) {
          Logger.error('[Debug.Rdb]', `deleteData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info('[Debug.Rdb]', `deleteData() finished: ${ret}`);
        callback(!resFlag);
      });
    }
  }
  //更新数据
  updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info('[Debug.Rdb]', 'updateDate() has no callback!');
      return;
    }
    let resFlag: boolean = false;
    const valueBucket: relationalStore.ValuesBucket = data;
    if (this.rdbStore) {
      this.rdbStore.update(valueBucket, predicates, (err, ret) => {
        if (err) {
          Logger.error('[Debug.Rdb]', `updateData() failed, err: ${err}`);
          callback(resFlag);
          return;
        }
        Logger.info('[Debug.Rdb]', `updateData() finished: ${ret}`);
        callback(!resFlag);
      });
    }
  }

  query(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      Logger.info('[Debug.Rdb]', 'query() has no callback!');
      return;
    }
    //columns表示要查询时，如果为空怎表示查询所有列
    if (this.rdbStore) {
      this.rdbStore.query(predicates, this.columns, (err, resultSet) => {
        if (err) {
          Logger.error('[Debug.Rdb]', `query() failed, err:  ${err}`);
          return;
        }
        Logger.info('[Debug.Rdb]', 'query() finished.');
        callback(resultSet); //查找成功则返回resultSet结果集
        resultSet.close(); //操作完成后关闭结果集
      });
    }
  }
}