package tools;

inline function pascalCase(s:String):String {
	if (s == null)
		return '';
	var a = s.split('-');
	return a.map(i -> firstUpperCase(i)).join('');
}

inline function firstUpperCase(s:String):String {
	final a = s.split('');
	a[0] = a[0].toUpperCase();
	return a.join('');
}
