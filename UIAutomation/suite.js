#import "jasmine-uiautomation.js"
#import "jasmine/lib/jasmine-core/jasmine.js"
#import "jasmine-uiautomation-reporter.js"

#import "specs/WalkingSkeleton-spec.js"

jasmine.getEnv().addReporter(new jasmine.UIAutomation.Reporter());
jasmine.getEnv().execute();

