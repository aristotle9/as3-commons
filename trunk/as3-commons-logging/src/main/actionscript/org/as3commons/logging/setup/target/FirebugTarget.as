/*
 * Copyright (c) 2008-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.logging.setup.target {
	
	import flash.utils.Dictionary;
	import org.as3commons.logging.level.DEBUG;
	import org.as3commons.logging.level.INFO;
	import org.as3commons.logging.level.WARN;
	import org.as3commons.logging.util.ErrorHolder;
	import org.as3commons.logging.util.LogMessageFormatter;
	
	import flash.events.ErrorEvent;
	import flash.external.ExternalInterface;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * <code>FirebugTarget</code> sends the output to the Firebug console. Also
	 * works with Google Chrome and others.
	 * 
	 * @see http://getfirebug.com/
	 * @author Martin Heidegger
	 * @version 1.0
	 * @since 2.1
	 */
	public class FirebugTarget implements IFormattingLogTarget {
		
		/** Default format used if non is passed in */
		public static const DEFAULT_FORMAT: String = "{time} {shortName}{atPerson} {message}";
		
		/** Formatter used to format the message */
		private var _formatter: LogMessageFormatter;
		
		/** Regular expression used to transform the value */
		private const _params: RegExp = /{([0-9]+)}/g;
		
		/** Depth of the introspection for objects */
		private var _depth: uint = 5;
		
		/**
		 * Creates new <code>FirebugTarget</code>
		 * 
		 * @param format Format to be used 
		 */
		public function FirebugTarget( format:String=null ) {
			this.format = format;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set format( format:String ): void {
			_formatter = new LogMessageFormatter( format||DEFAULT_FORMAT );
		}
		
		/**
		 * Maximum depth of introspection for objects to be rendered (default=5)
		 */
		public function set depth( depth:uint ): void {
			_depth = depth;
		}
		
		public function get depth():uint {
			return _depth;
		}
		
		/**
		 * @inheritDoc
		 */
		public function log(name:String, shortName:String, level:int,
							timeStamp:Number, message:*, params:Array, person:String=null):void {
			if( ExternalInterface.available ) {
				try {
					// Select the matching method
					var method: String;
					if( level == DEBUG ) method = "debug";
					else if( level == WARN ) method = "warn";
					else if( level == INFO ) method = "info";
					else method = "error";
					
					var msg: String;
					if( message is Function || message is Class ) {
						message = getQualifiedClassName( message );
					}
					var types: Dictionary = new Dictionary();
					if( message is String ) {
						// Modify the input to pass it properly to firefox
						//   
						//   as3commons pattern:  "some text {0} other text {1} and {0}", a, b
						//   firebug pattern: "some text %o other text %o and %o", a, b, a
						//   
						msg = message;
						var newParams: Array = [];
						var l: int = 0;
						msg = msg.replace( _params, function( ...rest:Array ): String {
							var result: String = "?";
							if( rest.length >= 2 ){
								var no: int = parseInt( rest[1] );
								var value: * = params[no];
								if( value is uint ) {
									result = "%i";
								} else if( value is Number ) {
									result = "%f";
								} else if( value is String ) {
									result = "%s";
									value = String( value ).split("\\").join("\\\\");
								} else if( value is Object ) {
									result = "%o";
									value = introspect( value, types, _depth );
								}
								// use question marks for null values
								if( result != "?" ) {
									newParams[l++] = value;
								}
							}
							return result;
						} );
						params = newParams;
					} else {
						// Other objects need to get a formatting string.
						if( message is uint || message is int ) {
							msg = "%i";
						} else if( message is Number ) {
							msg = "%f";
						} else {
							msg = "%o";
							message = introspect( message, types, _depth );
						}
						params = [message];
					}
					message = _formatter.format( name, shortName, level, timeStamp, msg, null, person ).split("\\").join("\\\\");
					params.unshift( message );
					params.unshift( "function(){ if(console){ console." + method +".apply(console,arguments);}}" );
					
					// Send it out!
					ExternalInterface.call.apply( ExternalInterface, params );
				} catch( e: Error ) {
				}
			}
		}
		
		/**
		 * Introspects a object, makes it js transferable and returns it.
		 * 
		 * @param value any object
		 * @return js valid representation
		 */
		private function introspect( value: *, map: Dictionary, levels: uint ): * {
			if( value is Boolean ) {
				return value;
			}
			if( value is Error || value is ErrorEvent ) {
				return new ErrorHolder( value );
			}
			var result: Object = map[ value ];
			if( !result ) {
				map[ value ] = result = {};
				var props: Array = getProps( value );
				for each( var prop: String in props ) {
					var child: * = value[ prop ];
					if( child is Function || child is Class ) {
						child = getQualifiedClassName( child );
					}
					if( child is String ) {
						child = String( child ).split("\\").join("\\\\");
					} else if( child is Object && !( child is Number || child is Boolean ) ) {
						if( levels > 0 ) {
							child = introspect( child, map, levels - 1 );
						} else {
							// Next Loop, introspection amount done
							continue;
						}
					}
					result[ prop ] = child;
				}
			}
			return result;
		}
	}
}
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

const DYNAMIC: Array = [];
const storage: Object = {};

function getProps( value: * ): Array {
	var cls: String = getQualifiedClassName( value );
	var result: Array = storage[ cls ];
	var l: int = 0;
	if( !result ) {
		var xml: XML = describeType( value );
		if( xml.@isDynamic == "true" ) {
			result = DYNAMIC;
		} else {
			result = [];
			var properties: XMLList = (
										xml["factory"]["accessor"] + xml["accessor"]
									  ).( @access=="readwrite" || @access=="readonly" )
									+ xml["factory"]["variable"] + xml["variable"];
			
			for each( var property: XML in properties ) {
				result[l++] = XML( property.@name ).toString();
			}
		}
		storage[cls] = result;
	}
	if( result == DYNAMIC ) {
		result = [];
		for( var i: String in value ) {
			result[l] = i;
		}
		return result;
	} else {
		return result;
	}
}