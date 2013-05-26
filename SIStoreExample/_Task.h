// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Task.h instead.

#import <CoreData/CoreData.h>


extern const struct TaskAttributes {
	__unsafe_unretained NSString *archived;
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *createAt;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *updateAt;
} TaskAttributes;

extern const struct TaskRelationships {
} TaskRelationships;

extern const struct TaskFetchedProperties {
} TaskFetchedProperties;








@interface TaskID : NSManagedObjectID {}
@end

@interface _Task : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TaskID*)objectID;





@property (nonatomic, strong) NSNumber* archived;



@property BOOL archivedValue;
- (BOOL)archivedValue;
- (void)setArchivedValue:(BOOL)value_;

//- (BOOL)validateArchived:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* content;



//- (BOOL)validateContent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createAt;



//- (BOOL)validateCreateAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updateAt;



//- (BOOL)validateUpdateAt:(id*)value_ error:(NSError**)error_;






@end

@interface _Task (CoreDataGeneratedAccessors)

@end

@interface _Task (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveArchived;
- (void)setPrimitiveArchived:(NSNumber*)value;

- (BOOL)primitiveArchivedValue;
- (void)setPrimitiveArchivedValue:(BOOL)value_;




- (NSString*)primitiveContent;
- (void)setPrimitiveContent:(NSString*)value;




- (NSDate*)primitiveCreateAt;
- (void)setPrimitiveCreateAt:(NSDate*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSDate*)primitiveUpdateAt;
- (void)setPrimitiveUpdateAt:(NSDate*)value;




@end
