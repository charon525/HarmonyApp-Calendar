/*账单二维表*/


//账目数据表
import relationalStore from '@ohos.data.relationalStore';
import ScheduleData from '../../../pages/ScheduleData';
import Rdb from '../rdb';

export default class scheduleTable {

  private scheduleTable = new Rdb('scheduleTable', 'CREATE TABLE IF NOT EXISTS scheduleTable(id INTEGER PRIMARY KEY AUTOINCREMENT,' +
  'title TEXT, date TEXT, year INTEGER, month INTEGER, note TEXT)',
    ['id', 'title', 'date', 'year', 'month', 'note']);

  constructor(callback: Function = () => {
  }) {
    this.scheduleTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {
  }) {
    this.scheduleTable.getRdbStore(callback);
  }
  //插入数据
  insertData(schedule: ScheduleData, callback: Function) {
    // 根据输入数据创建待插入的数据行
    const valueBucket: relationalStore.ValuesBucket = generateBucket(schedule);
    this.scheduleTable.insertData(valueBucket, callback);
  }
  //删除数据
  deleteData(schedule: ScheduleData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates('scheduleTable');
    //根据ID匹配待删除的数据行
    predicates.equalTo('id', schedule.id);
    this.scheduleTable.deleteData(predicates, callback);
  }
  //修改数据
  updateData(schedule: ScheduleData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(schedule);
    let predicates = new relationalStore.RdbPredicates('scheduleTable');
    //根据ID匹配待修改的数据行
    predicates.equalTo('id', schedule.id);
    this.scheduleTable.updateData(predicates, valueBucket, callback);
  }
  //通过类型查询
  query(key:string, value: any, callback: Function) {
    let predicates = new relationalStore.RdbPredicates('scheduleTable');
    //根据类型匹配要查找的数据行
    predicates.equalTo(key, value);
    this.scheduleTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      // 查找结果为空则返回空数组，否则返回查找结果数组
      if (count === 0 || typeof count === 'string') {
        console.log(`${'[Debug.scheduleTable]'}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: ScheduleData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: ScheduleData = {
            id: 0, title:'', date: '', year: 0, month: 0, note: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.title = resultSet.getString(resultSet.getColumnIndex('title'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getDouble(resultSet.getColumnIndex('year'))
          tmp.month = resultSet.getDouble(resultSet.getColumnIndex('month'))
          tmp.note = resultSet.getString(resultSet.getColumnIndex('note'))
          result.push(tmp);
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
  queryForsearch(value: any, callback: Function) {
    let predicates = new relationalStore.RdbPredicates('scheduleTable');
    //根据类型匹配要查找的数据行
    predicates.like('title', `%${value}%`)
      .or()
      .like('note', `%${value}%`);
    this.scheduleTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      // 查找结果为空则返回空数组，否则返回查找结果数组
      if (count === 0 || typeof count === 'string') {
        console.log(`${'[Debug.scheduleTable]'}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: ScheduleData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: ScheduleData = {
            id: 0, title:'', date: '', year: 0, month: 0, note: ''
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.title = resultSet.getString(resultSet.getColumnIndex('title'));
          tmp.date = resultSet.getString(resultSet.getColumnIndex('date'));
          tmp.year = resultSet.getDouble(resultSet.getColumnIndex('year'))
          tmp.month = resultSet.getDouble(resultSet.getColumnIndex('month'))
          tmp.note = resultSet.getString(resultSet.getColumnIndex('note'))
          result.push(tmp);
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
}
//生成数据行
function generateBucket(schedule: ScheduleData): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.title = schedule.title;
  obj.date = schedule.date;
  obj.year = schedule.year;
  obj.month = schedule.month;
  obj.note = schedule.note;
  return obj;
}