/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef CreateElementTransaction_h
#define CreateElementTransaction_h

#include "mozilla/EditorDOMPoint.h"
#include "mozilla/EditTransactionBase.h"
#include "nsCOMPtr.h"
#include "nsCycleCollectionParticipant.h"
#include "nsISupportsImpl.h"

class nsAtom;
class nsIContent;
class nsINode;

/**
 * A transaction that creates a new node in the content tree.
 */
namespace mozilla {

class EditorBase;
namespace dom {
class Element;
} // namespace dom

class CreateElementTransaction final : public EditTransactionBase
{
public:
  /**
   * Initialize the transaction.
   * @param aEditorBase     The provider of basic editing functionality.
   * @param aTag            The tag (P, HR, TABLE, etc.) for the new element.
   * @param aPointToInsert  The new node will be inserted before the child at
   *                        aPointToInsert.  If this refers end of the container
   *                        or after, the new node will be appended to the
   *                        container.
   */
  CreateElementTransaction(EditorBase& aEditorBase,
                           nsAtom& aTag,
                           const EditorRawDOMPoint& aPointToInsert);

  NS_DECL_ISUPPORTS_INHERITED
  NS_DECL_CYCLE_COLLECTION_CLASS_INHERITED(CreateElementTransaction,
                                           EditTransactionBase)

  NS_DECL_EDITTRANSACTIONBASE

  NS_IMETHOD RedoTransaction() override;

  already_AddRefed<dom::Element> GetNewNode();

protected:
  virtual ~CreateElementTransaction();

  /**
   * InsertNewNode() inserts mNewNode before the child node at mPointToInsert.
   */
  void InsertNewNode(ErrorResult& aError);

  // The document into which the new node will be inserted.
  RefPtr<EditorBase> mEditorBase;

  // The tag (mapping to object type) for the new element.
  RefPtr<nsAtom> mTag;

  // The DOM point we will insert mNewNode.
  RangeBoundary mPointToInsert;

  // The new node to insert.
  nsCOMPtr<dom::Element> mNewNode;
};

} // namespace mozilla

#endif // #ifndef CreateElementTransaction_h
