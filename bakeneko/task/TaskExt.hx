/*
 *  Copyright (c) 2015, Viachaslau Tratsiak.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */
package bakeneko.task;

import bakeneko.task.executors.ImmediateTaskExecutor;
import bakeneko.task.executors.TaskExecutor;

#if (flash || nme || openfl || lime)
    import bakeneko.task.executors.UiThreadTaskExecutor;
#end

#if (cpp || neko || java)
    import bakeneko.task.executors.BackgroundThreadTaskExecutor;
#end

class TaskExt {
	public static var IMMEDIATE_EXECUTOR(default, null) : TaskExecutor = new ImmediateTaskExecutor();
	
    #if (flash || nme || openfl || lime)
        private static var _UI_EXECUTOR : UiThreadTaskExecutor = null;
        public static var UI_EXECUTOR(get, null) : UiThreadTaskExecutor;

        @:noCompletion
        private static function get_UI_EXECUTOR() : UiThreadTaskExecutor {
            if (_UI_EXECUTOR == null) {
                _UI_EXECUTOR = new UiThreadTaskExecutor();
            }

            return _UI_EXECUTOR;
        }
    #end

    #if (cpp || neko || java)
        private static var _BACKGROUND_EXECUTOR : BackgroundThreadTaskExecutor = null;
        public static var BACKGROUND_EXECUTOR(get, null) : BackgroundThreadTaskExecutor;

        @:noCompletion
        private static function get_BACKGROUND_EXECUTOR() : BackgroundThreadTaskExecutor {
            if (_BACKGROUND_EXECUTOR == null) {
                _BACKGROUND_EXECUTOR = new BackgroundThreadTaskExecutor(8);
            }

            return _BACKGROUND_EXECUTOR;
        }
    #else
		public static var BACKGROUND_EXECUTOR = IMMEDIATE_EXECUTOR;
	#end
}
