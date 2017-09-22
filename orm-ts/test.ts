interface SchemaType{
	type: 'String' | 'Int' | 'Timestamp' | 'Boolean',
	field: string,
	default?: number | string | boolean
}


abstract class Model{

	private tableSchema: SchemaType[];
	protected tableName: string;
	protected primaryKey: string;
	protected timestamp: boolean = true;
	readonly save: Function;


	constructor(){
		this.tableName = this.getFormattedTableName(this.constructor['name']);

		// if the datasource is mongodb then it should be _id by default
		this.primaryKey = 'id';

		this.tableSchema = this.schema();

		this.save = this.saveFn;

	}


	abstract schema(): SchemaType[];


	/** ======== Private Methods ================== */
	/**
	 * getFormattedTableName()
	 * It will convert the `CamelCase` string into `camel_cases` string, and returns it.
	 * @param  {string} name [description]
	 * @return {string}      [description]
	 */
	private getFormattedTableName(name: string): string{
		// need add the pluralize functionality - https://github.com/blakeembrey/pluralize
		return name.split(/(?=[A-Z])/).join('_').toLowerCase();
	}

	private saveFn(){
		//orm.save(param)
		console.log(this)
	}


}

class User extends Model{
	
	//to set a table name explicitly
	//protected tableName: string = 'users';

	schema(): SchemaType[]{
		return [
			{field: 'name', type: 'String'},
			{field: 'email', type: 'String'},
			{field: 'password', type: 'String'},
			{field: 'is_active', type: 'Boolean', default: true},
		];
	}

}

let t = new User();
t.save();