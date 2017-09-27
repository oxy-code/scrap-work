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

		this.populateAttrs();

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
		console.log(this);
	}

	private populateAttrs(): void{
		/*this.tableSchema.forEach((value)=>{
			switch (value.type) {
				case "String":
					this[value.field] = value.default || '';
					break;
				case "Int":
					this[value.field] = value.default || 0;
					break;
				case "Timestamp":
					this[value.field] = value.default || '';
					break;
				case "Boolean":
					this[value.field] = (value.default === false) ? false : true;
					break;
			}
		});*/
	}


}

function ModelEx(Fn){
	console.log(Fn)
	let S = () => {}
	Object.defineProperty(S.prototype, "name", {
	    get: function() {
	        return 'hello';
	    }
	});
	Fn.prototype = Object.create(S.prototype);
	Fn.prototype.constructor = Fn;
	return Fn;
}

@ModelEx
class User extends Model{
	
	//to set a t
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
console.log(t)
//t.name = 'velu';
//t.name1='test';
//t.save();