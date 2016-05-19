/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "NSEnumerator.h"

@class DOMNode, EditableWebMessageDocument;

@interface _ComposeAttachmentEnumerator : NSEnumerator
{
    DOMNode *_currentNode;
    DOMNode *_containerNode;
    DOMNode *_endNode;
    EditableWebMessageDocument *_document;
    unsigned int _acceptDeleted:1;
    unsigned int _acceptNonDeleted:1;
}

- (id)initWithDocument:(id)arg1 options:(int)arg2 range:(id)arg3;
- (void)dealloc;
- (short)acceptNode:(id)arg1;
- (id)nextObject;
@property(retain) EditableWebMessageDocument *document; // @synthesize document=_document;
@property(retain) DOMNode *endNode; // @synthesize endNode=_endNode;
@property(retain) DOMNode *containerNode; // @synthesize containerNode=_containerNode;
@property(retain) DOMNode *currentNode; // @synthesize currentNode=_currentNode;

@end

