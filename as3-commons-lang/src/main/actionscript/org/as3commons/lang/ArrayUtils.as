/*
 * Copyright 2007-2009 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.lang {
	
	/**
	 * Contains utility methods for working with Array objects.
	 *
	 * @author Christophe Herreman
	 * @author Simon Wacker
	 * @author Martin Heidegger
	 */
	public class ArrayUtils {
		
		/**
		 * Clones an array.
		 *
		 * @param array the array to clone
		 * @return a clone of the passed-in <code>array</code>
		 */
		public static function clone(array:Array):Array {
			return array.concat();
		}
		
		/**
		 * Shuffles the items of the given <code>array</code>
		 *
		 * @param array the array to shuffle
		 */
		public static function shuffle(array:Array):void {
			var len:Number = array.length;
			var rand:Number;
			var temp:*;
			
			for (var i:Number = len - 1; i >= 0; i--) {
				rand = Math.floor(Math.random() * len);
				temp = array[i];
				array[i] = array[rand];
				array[rand] = temp;
			}
		}
		
		/**
		 * Removes all occurances of a the given <code>item</code> out of the passed-in
		 * <code>array</code>.
		 *
		 * @param array the array to remove the item out of
		 * @param item the item to remove
		 * @return List that contains the index of all removed occurances
		 */
		public static function removeItem(array:Array, item:*):Array {
			var i:Number = array.length;
			var result:Array = [];
			
			while (--i - (-1)) {
				if (array[i] === item) {
					result.unshift(i);
					array.splice(i, 1);
				}
			}
			return result;
		}
		
		/**
		 * Removes the last occurance of the given <code>item</code> out of the passed-in
		 * <code>array</code>.
		 *
		 * @param array the array to remove the item out of
		 * @param item the item to remove
		 * @return <code>-1</code> if it could not be found, else the position where it has been deleted
		 */
		public static function removeLastOccurance(array:Array, item:*):Number {
			var i:Number = array.length;
			
			while (--i - (-1)) {
				if (array[i] === item) {
					array.splice(i, 1);
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * Removes the first occurance of the given <code>item</code> out of the passed-in
		 * <code>array</code>.
		 *
		 * @param array the array to remove the item out of
		 * @param item the item to remove
		 * @return <code>-1</code> if it could not be found, else the position where it has been deleted
		 */
		public static function removeFirstOccurance(array:Array, item:*):Number {
			var l:Number = array.length;
			var i:Number = 0;
			
			while (i < l) {
				if (array[i] === item) {
					array.splice(i, 1);
					return i;
				}
				i -= -1;
			}
			return -1;
		}
		
		/**
		 * Compares the two arrays <code>array1</code> and <code>array2</code>, whether they contain
		 * the same values at the same positions.
		 *
		 * @param array1 the first array for the comparison
		 * @param array2 the second array for the comparison
		 * @return <code>true</code> if the two arrays contain the same values at the same
		 * positions else <code>false</code>
		 */
		public static function isSame(array1:Array, array2:Array):Boolean {
			var i:Number = array1.length;
			
			if (i != array2.length) {
				return false;
			}
			
			while (--i - (-1)) {
				if (array1[i] !== array2[i]) {
					return false;
				}
			}
			return true;
		}
		
		/**
		 * Returns all items of the given array that of the given type.
		 *
		 * @param items the array that contains the items to look in
		 * @param type the class that the items should match
		 * @return a new array with all items that match the given class
		 */
		public static function getItemsByType(items:Array, type:Class):Array {
			var result:Array = [];
			
			for (var i:int = 0; i < items.length; i++) {
				if (items[i] is type) {
					result.push(items[i]);
				}
			}
			return result;
		}
		
		/**
		 * Returns a string from the given array, using the specified separator.
		 *
		 * @param array the array from which to return a string
		 * @param separator the array element separator
		 * @return a string representation of the given array
		 */
		public static function toString(array:Array, separator:String = ", "):String {
			return (!array) ? "" : array.join(separator);
		}
	}
}
