//
//  MacroUtilities.h
//  Nest
//
//  Created by Manfred on 25/12/2016.
//
//

#ifndef MacroUtilities_h
#define MacroUtilities_h

#define _MODULE_CONSTRUCTOR_HIGH_PRIORITY __attribute__((constructor(101)))
#define _MODULE_CONSTRUCTOR_LOW_PRIORITY __attribute__((constructor(65535)))

#define _KEYWORD_FILE_SCOPE interface NSObject(metamacro_concat(__________nest_dynamic_property_getter_garbage_interface,__LINE__)) @end

#endif /* MacroUtilities_h */
