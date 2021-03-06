//
//  ItemCollectionViewController.swift
//  Klozet
//
//  Created by Huy Vo on 8/3/19.
//

import UIKit
import CoreData

private let cellNibName = "GridCollectionViewCell"
private let reuseIdentifier = "GridCell"
private let showItemEditSegueId = "showItemEdit"

class ItemCollectionViewController: UICollectionViewController {

    internal var categoryIndex: Int?
    
    private lazy var worker = ItemCollectionWorker()
    private var fetchedResultsController: NSFetchedResultsController<Item>!
    
    private var items = [Item]()
    
    private var numberOfItems: Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    // MARK: View cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = MyData().itemCategories[categoryIndex!].categoryName
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add item", style: .plain, target: self, action: #selector(addItemButtonTapped(_:)))
        
        fetchItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        let nib = UINib(nibName: cellNibName, bundle: nil)
        collectionView!.register(nib, forCellWithReuseIdentifier: reuseIdentifier)

//        fetchItems()
    }
    
    private func fetchItems() {
        fetchedResultsController = worker.fetchedResultsController
        
        do {
            try fetchedResultsController.performFetch()
            guard let itemSectionInfo = fetchedResultsController.sections?[0] else {
                numberOfItems = 0
                return
            }
            numberOfItems = itemSectionInfo.numberOfObjects
            
//            collectionView.reloadData()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: Interaction
    @objc private func addItemButtonTapped(_ sender: UIBarButtonItem) {
        promptUserToAddItem(on: sender)
    }

    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setupBackButton()
        
        if segue.identifier == showItemEditSegueId {
            let itemEditVC = segue.destination as! ItemEditViewController
            
            itemEditVC.newItemData = NewItem(categoryIndex: categoryIndex!, image: sender as! UIImage)
        }
    }
    
    private func setupBackButton()
    {
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
}


// MARK: - Collection View
extension ItemCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return numberOfItems
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GridCollectionViewCell
        
        let item = fetchedResultsController.object(at: indexPath)
        cell.itemImageView.image = worker.imageForItem(item)
        
        return cell
    }
}

extension ItemCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let itemWidth = view.frame.width / 3.2
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
}


//MARK: - Image Picker Delegate
extension ItemCollectionViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        performSegue(withIdentifier: showItemEditSegueId, sender: image)
    }
}
